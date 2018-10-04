//
//  CLLocationCoordinate2D+Distance.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/5/18.
//  Copyright © 2018 Me. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {
    func distance(from location: CLLocationCoordinate2D) -> CLLocationDistance {
        return CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
    }
}
