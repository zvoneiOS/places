//
//  HomeViewController.swift
//  places
//

import UIKit
import MapKit
import FirebaseDatabase

let cardReuseIdentifier = "CardCVC"
let sectionLeftRightInset:CGFloat = 32.0

class HomeViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var cardsContainerView: UIView!
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var detailLocationLabel: UILabel!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var locationManager:CLLocationManager?
    let geocoder = CLGeocoder()
    var ref: DatabaseReference!
    var dataViewSentDown = false
    var list = [Place]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupActionBar()
        self.setupMap()
        
        self.ref = Database.database().reference()
        self.getLocatins()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !dataViewSentDown {
            self.dataView.transform = CGAffineTransform.init(translationX: 0, y: self.dataView.frame.height)
            dataViewSentDown = true
        }
        self.setupContainerViewShadow()
        self.setupCollectionViewLayout()
        
    }
    
    func setupMap(){
        self.locationManager =  CLLocationManager.init()
        self.locationManager!.delegate = self
        self.locationManager!.desiredAccuracy = .greatestFiniteMagnitude
        self.locationManager!.requestWhenInUseAuthorization()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
    }
    
    func setupDetailsWithPlace(place:Place){
        self.detailNameLabel.text = place.name
        self.detailLocationLabel.text = place.country
        self.detailDescriptionLabel.text = place.description
    }
    
    func setupActionBar(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "add_plus"), style: .plain, target: self, action: #selector(newPlace))

    }
    
    func setupCollectionViewLayout() {
        guard let customCollectionView = self.cardsCollectionView.collectionViewLayout as? MyCollectionViewLayout else{
            return
        }
        customCollectionView.itemSize = CGSize.init(width: self.view.frame.width - 2 * sectionLeftRightInset, height: self.cardsCollectionView.frame.height)
        customCollectionView.minimumInteritemSpacing = 0
        customCollectionView.minimumLineSpacing = sectionLeftRightInset/2
        customCollectionView.scrollDirection = .horizontal
        customCollectionView.sectionInset = UIEdgeInsetsMake(0, sectionLeftRightInset, 0, sectionLeftRightInset)
    }
    
    func setupCollectionView() {
        self.cardsCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        self.cardsCollectionView.delegate = self
        self.cardsCollectionView.dataSource = self
        self.cardsCollectionView.register(UINib.init(nibName: "CardCVC", bundle: nil), forCellWithReuseIdentifier: cardReuseIdentifier)
    }
    
    func setupContainerViewShadow()  {
        self.cardsContainerView.layer.masksToBounds = false
        let shadowPath = UIBezierPath(roundedRect: self.cardsContainerView.bounds, cornerRadius: 0)
        self.cardsContainerView.layer.shadowColor = UIColor.black.cgColor
        self.cardsContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.cardsContainerView.layer.shadowOpacity = 0.7
        self.cardsContainerView.layer.shadowPath = shadowPath.cgPath
    }
    
    @objc func newPlace(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChoosePositionViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func closeDataView(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.dataView.transform = CGAffineTransform.init(translationX: 0, y: self.dataView.frame.height)
        }
    }
    
    
    func getLocatins()  {
        self.activityIndicator.startAnimating()
        ref.child("locations").observe(.value) {[unowned self] (snapshot) in
            self.list.removeAll()
            self.mapView.removeAnnotations(self.mapView.annotations)
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let value = rest.value as! NSDictionary
                let place = Place.init(name: value["name"] as! String,
                                       latitude: value["latitude"] as! Double,
                                       longitude: value["longitude"] as! Double,
                                       imageUrl: value["imageUrl"] as! String,
                                       description: value["description"] as! String,
                                       country: value["country"] as! String)
                let placeAnnotation = PlaceAnnotation.init(place: place, positionInList: self.list.count)
                self.mapView.addAnnotation(placeAnnotation)
                self.list.append(place)
            }
            self.activityIndicator.stopAnimating()
            self.cardsCollectionView.reloadData()
            self.cardsCollectionView.layoutIfNeeded()
            self.setupCardSizeAnimation()
            self.scrollViewDidEndDecelerating(self.cardsCollectionView)
        }
    }

}

extension HomeViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationManager!.startUpdatingLocation()
        default:
            self.locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PlaceAnnotation else { return nil }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 0)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is PlaceAnnotation{
          self.cardsCollectionView.scrollToItem(at: IndexPath.init(row: (view.annotation as! PlaceAnnotation).positionInList, section: 0), at: .centeredHorizontally, animated: true)
        }
        
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func setupCardSizeAnimation(){
        for cell in self.cardsCollectionView.visibleCells {
            let realCenter = self.cardsCollectionView.convert(cell.center, to: self.cardsCollectionView.superview)
            var koefY = self.cardsCollectionView.center.x - realCenter.x
            if(koefY < 0){koefY = -1 * koefY}
            var koefX = self.cardsCollectionView.frame.width - 1/30 * koefY
            koefX = koefX / self.cardsCollectionView.frame.width
            koefY = self.cardsCollectionView.frame.width - 1/7*koefY
            koefY = koefY / self.cardsCollectionView.frame.width
            cell.transform = CGAffineTransform.init(scaleX: koefX, y: koefY)
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round((scrollView.contentOffset.x) / CGFloat(self.view.frame.width - 2 * sectionLeftRightInset + sectionLeftRightInset/2)))
        let place = self.list[page]
        let latitude = place.latitude
        let longitude = place.longitude
        self.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: .init(latitudeDelta: 1, longitudeDelta: 1)), animated: true)
        var annotationToSelect:MKAnnotation?
        for a in self.mapView.annotations{
            if(a.coordinate.longitude == longitude && a.coordinate.latitude == latitude){
                annotationToSelect = a
            }
        }
        if annotationToSelect != nil {
            self.mapView.selectAnnotation(annotationToSelect!, animated: true)
        }
        self.setupDetailsWithPlace(place: place)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.setupCardSizeAnimation()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cardReuseIdentifier, for: indexPath) as! CardCVC
        cell.setupWithPlace(place: list[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3, animations: {
            self.dataView.transform = CGAffineTransform.identity
        })
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.view.frame.width - 2 * sectionLeftRightInset, height: self.cardsCollectionView.frame.height)
    }
}
