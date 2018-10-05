//
//  MapViewContentDrawer.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/5/18.
//  Copyright © 2018 Me. All rights reserved.
//

import RxSwift
import GoogleMaps

/// MapViewContentDrawer is the class that is responsible for drawing the stations markers on the map,
/// animating bus route, and simulating bus tracking
class MapViewContentDrawer: NSObject {
    
    /// The GMSMapView where the drawings happen
    private let mapView: GMSMapView
    private let disposeBag = DisposeBag()
    
    /// A CAShapeLayer that is used to draw the bus route with animation
    private var shapeLayer: CAShapeLayer!
    
    /// The list of stations to be rendered on the map
    private var stations: [Station]!
    
    /// The single initializer for creating a MapViewContentDrawer object
    ///
    /// - Parameter mapView: The GMSMapView where the drawings happen
    init(mapView: GMSMapView) {
        self.mapView = mapView
    }
    
    // MARK: - Public
    
    /// A method that draws the stations on the map
    /// - The drawing process includes clearing any old marker or layers drawn on the map
    /// - Focusing only on the area that contains the bus stations,
    /// - Drawing the station marker with animation,
    /// - Animating the bus route
    /// - And finally simulating a bus moving on the map
    ///
    /// - Parameter stations: The list of stations to be rendered on the map
    func draw(stations: [Station]) {
        self.stations = stations
        
        clearMap()
        
        let positions = stations.map({ $0.location.toLocationCoordinate2D })
        focusMapCamera(on: positions)
        drawMarkers(for: stations, on: mapView) { [weak self] in
            self?.drawaAnimatedPath(for: positions)
        }
    }
    
    // MARK: - Private
    
    /// This method moves the map to the area containg only the given position while zooming in
    ///
    /// - Parameter positions: The positions to be focused on
    private func focusMapCamera(on positions: [CLLocationCoordinate2D]) {
        let bounds = GMSCoordinateBounds(path: positions.toGMSPath)
        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets(all: 60))!
        mapView.animate(to: camera)
    }
    
    /// Draw station markers for the given stations with animation on periodic intervals
    ///
    /// - Parameters:
    ///   - stations: The list of stations to be rendered on the map
    ///   - mapView: The GMSMapView where the drawings happen
    ///   - completion: A closure to be called after finishing the markers rendering
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
    
    /// This method removes any layers or animation layers drawn on the map
    /// as well as clreaing any GMSMarker or GMSPath drawn.
    /// This method usually used before rendering any new stations list
    private func clearMap() {
        shapeLayer?.removeAnimation(forKey: "strokeEnd")
        shapeLayer?.removeFromSuperlayer()
        mapView.clear()
    }
    
    // MARK: - Path animation
    
    /// Draw an animated path for the given CLLocationCoordinate2D list
    ///
    /// - Parameter positions: The list of locations to be drawn
    private func drawaAnimatedPath(for positions: [CLLocationCoordinate2D]) {
        shapeLayer = shapeLayerFrom(positions: positions, mapView: mapView)
        
        shapeLayer.zPosition = 1
        mapView.layer.addSublayer(shapeLayer)
        
        animate(shapeLayer: shapeLayer)
    }
    
    /// A method that creates a CAShapeLayer for a given list of positions
    ///
    /// - Parameters:
    ///   - positions: The list of locations to be drawn
    ///   - mapView: The GMSMapView where the drawings happen, used to calculate the
    /// projection points for the positions on the map
    /// - Returns: A CAShapeLayer representing the positions list
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
    
    /// A method that animates the drawing of the bus route
    ///
    /// - Parameter shapeLayer: The CAShapeLayer to be animated
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
    
    /// A method that simulate a bus moving on its route
    ///
    /// - Parameter positions: The list of points where the bus should pass through
    private func simulateBusTracking(positions: [CLLocationCoordinate2D]) {
        let marker = markerForBus()
        marker.map = mapView
        
        let animation = busAnimation(for: positions)
        
        marker.layer.add(animation, forKey: "track")
    }
    
    /// A helper method that creates and configures a GMSMarker representing the bus
    ///
    /// - Returns: The created GMSMarker
    private func markerForBus() -> GMSMarker {
        let marker = GMSMarker()
        marker.appearAnimation = .pop
        marker.icon = Icon.busMarker
        marker.zIndex = 1
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        
        return marker
    }
    
    /// A method that creates an animation which simulates a bus moving on a route on the map and caculates the timing
    ///
    /// - Parameter positions: The list of points where the bus should pass through
    /// - Returns: A CAAnimation object to be used for animating the bus marker
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
    
    /// A method that caculates the animation timing based on the distance between each station in order to maintain
    /// a constant speed for the bus.
    /// The timing is calculated by first, summing the distances between the stations, then normalizing them so that
    /// the sum of all the normalized values (relative distances) is equal to 1, which is used after that for
    /// calculating the keyframes times
    ///
    /// - Parameter positions: The list of locations to be used in generating the timing
    /// - Returns: A list of relative times equals to the number of positions
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
        
        // This is a workaround an issue where the shapeLayer is removed before the GMSPath is drawn
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.shapeLayer.removeFromSuperlayer()
        }
        
        simulateBusTracking(positions: positions)
    }
}
