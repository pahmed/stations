//
//  Array+Extensions.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation
import GoogleMaps

extension Array where Element == CLLocationCoordinate2D {
    
    /// Converts array of CLLocationCoordinate2D into GMSPath
    var toGMSPath: GMSPath {
        return self.reduce(GMSMutablePath(), { (path, coord) in
            path.add(coord)
            return path
        })
    }
}

