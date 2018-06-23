//
//  PlaceAnnotation.swift
//  places
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let positionInList: Int
    
    init(place:Place, positionInList:Int) {
        self.title = place.name
        self.locationName = place.name
        self.discipline = place.name
        self.coordinate = CLLocationCoordinate2D.init(latitude: place.latitude, longitude: place.longitude)
        self.positionInList = positionInList
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
