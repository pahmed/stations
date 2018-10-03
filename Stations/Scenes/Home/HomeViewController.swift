//
//  HomeViewController.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift

protocol HomeDisplayLogic {
    
}

class HomeViewController: UIViewController {
    
    private var mapView: GMSMapView!
    private var disposeBag = DisposeBag()
    
    lazy var interactor: HomeBusinessLogic = {
        return HomeInteractor(presenter: HomePresenter(displayer: self))
    }()
    var shapeLayer: CAShapeLayer!
    var selectedLine: Line?
    var animation: CABasicAnimation!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case .some("lines"):
            (segue.destination as! LinesViewController).delegate = self
            
        default:
            fatalError("unhandled segue")
        }
    }
    
    // MARK: - Private
    
    private func setupMapView() {
        mapView = GMSMapView(frame: CGRect.zero)
        mapView.isMyLocationEnabled = true
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(mapView, at: 0)
        
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        mapView.delegate = self
    }
    
    private func clearMap() {
        shapeLayer?.removeAnimation(forKey: "strokeEnd")
        shapeLayer?.removeFromSuperlayer()
        mapView.clear()
    }
    
    private func draw(locations: [Location]) {
        clearMap()
        
        let positions = locations.map({ $0.toLocationCoordinate2D })
        let path = self.path(for: positions)
        let bounds = GMSCoordinateBounds(path: path)
        
        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60))!
        mapView.animate(to: camera)
        
        Observable<Int>
            .interval(RxTimeInterval(0.2), scheduler: MainScheduler.instance)
            .take(positions.count)
            .delaySubscription(0.2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.showMarker(for: positions[index])
                }, onCompleted: { [weak self] in
                    self?.drawNativePath(for: positions)
            }).disposed(by: disposeBag)
    }
    
    private func showMarker(for position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "EndPoint")
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.appearAnimation = .pop
        marker.map = mapView
    }
    
    private func drawNativePath(for positions: [CLLocationCoordinate2D]) {
        var points = positions
            .map({ self.mapView.projection.point(for: $0) })
        
        let bezierPath = UIBezierPath()
        
        let first = points.removeFirst()
        bezierPath.move(to: first)
        
        for point in points {
            bezierPath.addLine(to: point)
        }
        
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = Color.accent.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = bezierPath.cgPath
        
        mapView.layer.addSublayer(shapeLayer)
        
        animate(shapeLayer: shapeLayer)
    }
    
    private func animate(shapeLayer: CAShapeLayer) {
        animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut) // animation curve is Ease Out
        animation.fillMode = CAMediaTimingFillMode.both // keep to value after finishing
        animation.isRemovedOnCompletion = true // don't remove after finishing
        animation.delegate = self
        
        shapeLayer.add(animation, forKey: animation.keyPath)
    }
    
    private func path(for positions: [CLLocationCoordinate2D]) -> GMSPath {
        let path = GMSMutablePath()
        
        for position in positions {
            path.add(position)
        }
        
        return path
    }
    
    private func drawPath(for positions: [CLLocationCoordinate2D]) {
        let path = self.path(for: positions)
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3
        polyline.strokeColor = .red
        polyline.map = self.mapView
    }
    
}

// MARK: - DisplayLogic

extension HomeViewController: HomeDisplayLogic {
    
}

// MARK: - GMSMapViewDelegate

extension HomeViewController: GMSMapViewDelegate {
    
}

// MARK: - LinesViewControllerDelegate

extension HomeViewController: LinesViewControllerDelegate {
    func linesViewController(_ linesViewController: LinesViewController, didSelect line: Line) {
        selectedLine = line
        draw(locations: line.stations.map({ $0.location }))
    }
}

// MARK: - CAAnimationDelegate

extension HomeViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let positions = selectedLine!.stations.map({ $0.location.toLocationCoordinate2D })
        
        drawPath(for: positions)
        
        Observable<Int>
            .interval(RxTimeInterval(0.2), scheduler: MainScheduler.instance)
            .take(1)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.shapeLayer.removeFromSuperlayer()
            }).disposed(by: disposeBag)
    }
}
