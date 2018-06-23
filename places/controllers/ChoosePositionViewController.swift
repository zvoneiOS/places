//
//  ChoosePositionViewController.swift
//  places
//

import UIKit
import MapKit

class ChoosePositionViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var confirmPositionButton: UIButton!
    
    var geocoder:CLGeocoder?
    var placemark: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Choose location"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupConfirmButton()
    }
    
    func setupConfirmButton(){
        self.confirmPositionButton.layer.cornerRadius = 5
        let shadowPath = UIBezierPath(roundedRect: self.confirmPositionButton.bounds, cornerRadius: self.confirmPositionButton.layer.cornerRadius)
        self.confirmPositionButton.layer.shadowColor = UIColor.black.cgColor
        self.confirmPositionButton.layer.shadowOffset = CGSize(width: 0, height: 0);
        self.confirmPositionButton.layer.shadowOpacity = 0.7
        self.confirmPositionButton.layer.shadowPath = shadowPath.cgPath
    }
    
    @IBAction func confirmClicked(_ sender: Any) {
        let centerLocation = mapView.centerCoordinate
        let location = CLLocation(latitude: centerLocation.latitude, longitude: centerLocation.longitude)
        geocoder = CLGeocoder()
        geocoder!.reverseGeocodeLocation(location, preferredLocale: Locale.init(identifier: "en_US"), completionHandler:{ (placemarks, error) in
            if error == nil, let placemark = placemarks, !placemark.isEmpty {
                self.placemark = placemark.first
            }
            self.parsePlacemarks(location:location)
        })
    }
    
    func parsePlacemarks(location:CLLocation) {
            if let placemark = placemark {
                if let city = placemark.locality, !city.isEmpty {
                    self.startDescriptionController(location: location, locationName: city)
                }else if let country = placemark.country, !country.isEmpty {
                    self.startDescriptionController(location: location, locationName: country)
                }else{
                    self.startDescriptionController(location: location, locationName: "")
                }
            }else{
                self.startDescriptionController(location: location, locationName: "")
            }
    }
    
    func startDescriptionController(location:CLLocation, locationName:String){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "positionEdit") as! AddPositionDetailsViewController
        vc.location = location
        vc.cityName = locationName
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
