//
//  MapViewContentDrawer.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/5/18.
//  Copyright © 2018 Me. All rights reserved.
//

import RxSwift
import GoogleMaps

class MapViewContentDrawer: NSObject {
    
    private let mapView: GMSMapView
    private let disposeBag = DisposeBag()
    
    private var shapeLayer: CAShapeLayer!
    private var stations: [Station]!
    
    init(mapView: GMSMapView) {
        self.mapView = mapView
    }
    
    // MARK: - Public
    
    func draw(stations: [Station]) {
        self.stations = stations
        
        clearMap()
        
        let positions = stations.map({ $0.location.toLocationCoordinate2D })
        focusMapCamera(on: positions)
        drawMarkers(for: stations, on: mapView) { [weak self] in
            self?.drawaAnimatedPath(for: positions)
        }
    }
    
    private func focusMapCamera(on positions: [CLLocationCoordinate2D]) {
        let bounds = GMSCoordinateBounds(path: positions.toGMSPath)
        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets(all: 60))!
        mapView.animate(to: camera)
    }
    
    private func drawMarkers(for stations: [Station], on mapView: GMSMapView, completion: @escaping () -> Void) {
        Observable<Int>
            .interval(RxTimeInterval(0.2), scheduler: MainScheduler.instance)
            .take(stations.count)
            .delaySubscription(0.2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { index in
                let markerImage = Icon.defaultMarker
                mapView.showMarker(for: stations[index], markerImage: markerImage)
                }, onCompleted: completion)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private
    
    private func clearMap() {
        shapeLayer?.removeAnimation(forKey: "strokeEnd")
        shapeLayer?.removeFromSuperlayer()
        mapView.clear()
    }
    
    // MARK: - Path animation
    
    private func drawaAnimatedPath(for positions: [CLLocationCoordinate2D]) {
        shapeLayer = shapeLayerFrom(positions: positions, mapView: mapView)
        
        shapeLayer.zPosition = 1
        mapView.layer.addSublayer(shapeLayer)
        
        animate(shapeLayer: shapeLayer)
    }
    
    func shapeLayerFrom(positions: [CLLocationCoordinate2D], mapView: GMSMapView) -> CAShapeLayer {
        var points = positions.map({ mapView.projection.point(for: $0) })
        
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
    
    private func animate(shapeLayer: CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.delegate = self
        
        shapeLayer.add(animation, forKey: animation.keyPath)
    }
    
    // MARK: - Bus Tracking
    
    private func simulateBusTracking(positions: [CLLocationCoordinate2D]) {
        let marker = markerForBus()
        marker.map = mapView
        
        let animation = busAnimation(for: positions)
        
        marker.layer.add(animation, forKey: "track")
    }
    
    private func markerForBus() -> GMSMarker {
        let marker = GMSMarker()
        marker.appearAnimation = .pop
        marker.icon = Icon.busMarker
        marker.zIndex = 1
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        
        return marker
    }
    
    private func busAnimation(for positions: [CLLocationCoordinate2D]) -> CAAnimation {
        let times = keyframesTimes(for: positions)
        
        let horizontal = CAKeyframeAnimation(keyPath: "longitude")
        horizontal.values = positions.map({ $0.longitude })
        horizontal.keyTimes = times as [NSNumber]
        
        let vertical = CAKeyframeAnimation(keyPath: "latitude")
        vertical.values = positions.map({ $0.latitude })
        vertical.keyTimes = times as [NSNumber]
        
        let group = CAAnimationGroup()
        group.animations = [horizontal, vertical]
        group.duration = Constants.Animation.simulatedBusTrackingDuration
        group.repeatCount = Constants.Animation.simulatedBusTrackingRepeatCount
        
        return group
    }
    
    private func keyframesTimes(for positions: [CLLocationCoordinate2D]) -> [Double] {
        let distances = zip(positions, positions[1...]).compactMap({ $0.0.distance(from: $0.1) })
        let totalDistance = distances.reduce(0.0, +)
        let relativeDistances = distances.map({ $0 / totalDistance })
        
        let times = relativeDistances.reduce([0.0]) { result, value in
            var newResult = result
            newResult.append(result.last! + value)
            return newResult
        }
        
        return times
    }
    
}

// MARK: - CAAnimationDelegate

extension MapViewContentDrawer: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let positions = stations.map({ $0.location.toLocationCoordinate2D })
        
        mapView.drawGMSPath(for: positions)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.shapeLayer.removeFromSuperlayer()
        }
        
        simulateBusTracking(positions: positions)
    }
}
