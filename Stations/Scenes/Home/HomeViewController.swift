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
import Hero

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
    var callout: CalloutViewController!
    var snapshot: UIView?
    
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
    
    private func snapshotFor(callout: CalloutViewController, in view: UIView) -> UIView {
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
    
    private func renderCalloutSnapshot() {
        snapshot?.removeFromSuperview()
        snapshot = self.snapshotFor(callout: self.callout, in: self.view)
        view.addSubview(snapshot!)
    }
    
    private func presentCallout(from point: CGPoint, for station: Station, animated: Bool = true, completion: (() -> Void)? = nil) {
        callout = CalloutViewController.calloutWith(station: station)
        callout.modalPresentationStyle = .popover
        
        callout.handleTap = {
            self.renderCalloutSnapshot()
            
            let detailsVC = StationDetailsViewController.controllerWith(station: station)
            detailsVC.handleDismiss = { vc in
                vc.dismiss(animated: true)
                self.presentCallout(from: point, for: station, animated: false) {
                    self.snapshot!.removeFromSuperview()
                }
            }
            
            self.callout.dismiss(animated: false)
            
            self.present(detailsVC, animated: true)
        }
        
        let popover = callout.popoverPresentationController!
        popover.delegate = self
        
        let rect = CGRect(origin: point, size: CGSize.zero).inset(by: UIEdgeInsets(all: 15))
        
        popover.permittedArrowDirections = [.down]
        popover.sourceView = mapView
        popover.sourceRect = rect
        present(callout, animated: animated, completion: completion)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
    
    private func draw(stations: [Station]) {
        clearMap()
        
        let positions = stations.map({ $0.location.toLocationCoordinate2D })
        let bounds = GMSCoordinateBounds(path: positions.toGMSPath)
        
        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets(all: 60))!
        mapView.animate(to: camera)
        
        Observable<Int>
            .interval(RxTimeInterval(0.2), scheduler: MainScheduler.instance)
            .take(positions.count)
            .delaySubscription(0.2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.showMarker(at: positions[index], for: stations[index])
                }, onCompleted: { [weak self] in
                    self?.drawNativePath(for: positions)
            }).disposed(by: disposeBag)
    }
    
    private func showMarker(at position: CLLocationCoordinate2D, for station: Station) {
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "EndPoint")
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.appearAnimation = .pop
        marker.map = mapView
        marker.userData = station
    }
    
    private func shapeLayerFrom(positions: [CLLocationCoordinate2D]) -> CAShapeLayer {
        var points = positions
            .map({ self.mapView.projection.point(for: $0) })
        
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
    
    private func drawNativePath(for positions: [CLLocationCoordinate2D]) {
        shapeLayer = shapeLayerFrom(positions: positions)

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
    
    private func drawPath(for positions: [CLLocationCoordinate2D]) {
        let polyline = GMSPolyline(path: positions.toGMSPath)
        polyline.strokeWidth = 3
        polyline.strokeColor = Color.accent
        polyline.map = self.mapView
    }
    
}

// MARK: - DisplayLogic

extension HomeViewController: HomeDisplayLogic {
    
}

// MARK: - GMSMapViewDelegate

extension HomeViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let point = mapView.projection.point(for: marker.position)
        
        let station = marker.userData as! Station
        
        presentCallout(from: point, for: station)
        return true
    }
    
}

// MARK: - LinesViewControllerDelegate

extension HomeViewController: LinesViewControllerDelegate {
    func linesViewController(_ linesViewController: LinesViewController, didSelect line: Line) {
        selectedLine = line
        draw(stations: line.stations)
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

// MARK: - UIPopoverPresentationControllerDelegate

extension HomeViewController: UIPopoverPresentationControllerDelegate {
    
}
