//
//  Models.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation
import CoreLocation

struct LinesResponse: Codable {
    let lines: [Line]
}

struct Line: Codable {
    let name: String
    let stations: [Station]
}

struct Station: Codable {
    let id: Int
    let name: String
    let img_url: String
    let address: String
    let location: Location
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    
    var toLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
