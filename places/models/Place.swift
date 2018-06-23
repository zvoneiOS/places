//
//  File.swift
//  places
//

import Foundation

struct Place {
    let name:String
    let latitude:Double
    let longitude:Double
    let imageUrl:String
    let description:String
    let country:String
    
    init(name:String, latitude:Double, longitude: Double, imageUrl:String, description:String, country:String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.imageUrl = imageUrl
        self.description = description
        self.country = country
    }
}
