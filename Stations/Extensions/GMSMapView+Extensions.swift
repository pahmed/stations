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
    
    func shapeLayerFrom(positions: [CLLocationCoordinate2D]) -> CAShapeLayer {
        var points = positions.map({ [unowned self] in self.projection.point(for: $0) })
        
        let bezierPath = UIBezierPath()
        
        let first = points.removeFirst()
        bezierPath.move(to: first)
        
        for point in points {
            bezierPath.addLine(to: point)
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = Color.accent.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = bezierPath.cgPath
        
        return shapeLayer
    }
    
    func snapshotFor(callout: CalloutViewController, in view: UIView) -> UIView {
        let snapshot = callout.view.clone()!
        snapshot.layer.cornerRadius = 12
        snapshot.clipsToBounds = true
        snapshot.frame = view.convert(callout.view.frame, from: callout.view.superview)
        
        snapshot.hero.id = "container"
        
        let imageView = snapshot.viewWithTag(1)!
        imageView.layer.cornerRadius = 8
        imageView.hero.id = "image"
        
        snapshot.viewWithTag(2)!.hero.id = "name"
        snapshot.viewWithTag(3)!.hero.id = "address"
        
        return snapshot
    }
    
    func drawPath(for positions: [CLLocationCoordinate2D]) {
        let polyline = GMSPolyline(path: positions.toGMSPath)
        polyline.strokeWidth = 3
        polyline.strokeColor = Color.accent
        polyline.map = self
    }
    
}
