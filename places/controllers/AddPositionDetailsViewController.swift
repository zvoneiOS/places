//
//  AddPositionDetailsViewController.swift
//  places
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import MapKit

class AddPositionDetailsViewController: UIViewController {

    @IBOutlet weak var nameInputField: UITextField!
    @IBOutlet weak var descriptionInputField: UITextView!
    
    let uploadButton = ProgressButton(frame: CGRect(x: 0, y: 0, width: 1, height: 60))
    var imageForUpload:UIImage?
    var location:CLLocation?
    var cityName:String?
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.title = "Details"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Photo", style: .plain, target: self, action: #selector(photoTaped))
        self.nameInputField.inputAccessoryView = uploadButton
        self.descriptionInputField.inputAccessoryView = uploadButton
        self.setupUploadButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nameInputField.becomeFirstResponder()
    }
    
    func setupUploadButton(){
        self.uploadButton.resetButton()
        self.uploadButton.buttonClicked = {[unowned self] in
            if self.checkPlaceName() && self.checkPlaceDescription(){
                self.startUpload()
            }
        }
    }
    
    func checkPlaceName() -> Bool {
        if let placeName = self.nameInputField.text, placeName.count > 0 {
            return true
        }else{
            self.presentError(error: "Please input place name")
            return false
        }
    }
    
    func checkPlaceDescription() -> Bool {
        if let placeDesc = self.descriptionInputField.text, placeDesc.count > 0 {
            return true
        }else{
            self.presentError(error: "Please input place description")
            return false
        }
    }
    
    func startUpload(){
        guard let placeImage = self.imageForUpload else {
            self.presentError(error: "Please input place photo")
            return
        }
        self.uploadPhoto(image: placeImage) {[unowned self] (url) in
            if !url.isEmpty {
                self.uploadPlaceWith(photoUrl: url)
            }
        }
    }
    
    func uploadPlaceWith(photoUrl:String){
        self.ref.child("locations").childByAutoId().setValue([
            "country": self.cityName!,
            "description": self.descriptionInputField.text!,
            "imageUrl": photoUrl,
            "latitude": self.location!.coordinate.latitude,
            "longitude": self.location!.coordinate.longitude,
            "name": self.nameInputField.text! ]) { [unowned self](error, ref) in
                if error == nil {
                    self.navigationController?.popToRootViewController(animated: true)
                }else {
                    self.presentError(error: error!.localizedDescription)
                }
        }
    }
    
    func presentError(error:String){
        let errorVC = UIAlertController.init(title: error, message: nil, preferredStyle: .alert)
        errorVC.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        self.present(errorVC, animated: true, completion: nil)
    }
    
    func uploadPhoto(image:UIImage, closure: @escaping (_ url:String) -> Void){
        self.uploadButton.setUploading()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let data = UIImageJPEGRepresentation(image, 0.8)!
        let imageRef = storageRef.child("locations/" + self.nameInputField.text! + Date().timeIntervalSince1970.description)
        let uploadTask = imageRef.putData(data, metadata: metadata)
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            self.uploadButton.setupProgress(progress: Float(percentComplete))
        }
        
        uploadTask.observe(.success) { snapshot in
            imageRef.downloadURL(completion: { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    closure(downloadURL.description)
                })
            })
        }
        
        uploadTask.observe(.failure) { snapshot in
            self.uploadButton.resetButton()
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    break
                case .cancelled:
                    // User canceled the upload
                    break
                    
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
    }
}

extension AddPositionDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @objc func photoTaped(){
        let menuVC = UIAlertController.init(title: "Add photo", message: nil, preferredStyle: .actionSheet)
        menuVC.addAction(UIAlertAction.init(title: "Camera", style: .default, handler: { _ in
            self.startCameraPicker()
        }))
        menuVC.addAction(UIAlertAction.init(title: "Photos", style: .default, handler: { _ in
            self.startLibraryPicker()
        }))
        menuVC.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(menuVC, animated: true, completion: nil)
    }
    
    func startCameraPicker(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.cameraCaptureMode = .photo
        picker.modalPresentationStyle = .fullScreen
        picker.delegate = self
        self.present(picker,animated: true,completion: nil)
    }
    
    func startLibraryPicker(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imageForUpload = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
