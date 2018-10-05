//
//  GMSMapView+Extensions.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import GoogleMaps

extension GMSMapView {
    func showMarker(for station: Station, markerImage: UIImage) {
        let marker = GMSMarker(position: station.location.toLocationCoordinate2D)
        marker.icon = markerImage
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.appearAnimation = .pop
        marker.map = self
        marker.layer.zPosition = 2
        marker.userData = station
    }
    
    func drawGMSPath(for positions: [CLLocationCoordinate2D]) {
        let polyline = GMSPolyline(path: positions.toGMSPath)
        polyline.strokeWidth = 3
        polyline.strokeColor = Color.accent
        polyline.map = self
    }
    
}
