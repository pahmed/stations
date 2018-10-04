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
    
    @IBOutlet weak var linesBottomConstraint: NSLayoutConstraint!
    private var mapView: GMSMapView!
    private var disposeBag = DisposeBag()
    
    lazy var interactor: HomeBusinessLogic = {
        return HomeInteractor(presenter: HomePresenter(displayer: self))
    }()
    var shapeLayer: CAShapeLayer!
    var selectedLine: Line?
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
    
    private func renderCalloutSnapshot() {
        snapshot?.removeFromSuperview()
        snapshot = mapView.snapshotFor(callout: callout, in: view)
        view.addSubview(snapshot!)
    }
    
    private func presentCallout(from point: CGPoint, for station: Station, animated: Bool = true, completion: (() -> Void)? = nil) {
        callout = CalloutViewController.calloutWith(station: station)
        callout.modalPresentationStyle = .popover
        
        callout.handleTap = { [weak self] in
            self?.renderCalloutSnapshot()
            
            let detailsVC = StationDetailsViewController.controllerWith(station: station)
            detailsVC.handleDismiss = { vc in
                vc.dismiss(animated: true)
                self?.presentCallout(from: point, for: station, animated: false) {
                    self?.snapshot!.removeFromSuperview()
                }
            }
            
            self?.callout.dismiss(animated: false)
            
            self?.present(detailsVC, animated: true)
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
                let markerImage = Icon.defaultMarker
                self?.mapView.showMarker(for: stations[index], markerImage: markerImage)
                }, onCompleted: { [weak self] in
                    self?.drawNativePath(for: positions)
            }).disposed(by: disposeBag)
    }
    
    private func drawNativePath(for positions: [CLLocationCoordinate2D]) {
        shapeLayer = mapView.shapeLayerFrom(positions: positions)

        shapeLayer.zPosition = 1
        mapView.layer.addSublayer(shapeLayer)
        
        animate(shapeLayer: shapeLayer)
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
    
    private func showLinesView() {
        linesBottomConstraint.constant = 16.0
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 5,
            options: .curveEaseInOut,
            animations: {
                self.view.layoutIfNeeded()
        }, completion: nil)
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
    
    func linesViewControllerDidLoadLines(_ linesViewController: LinesViewController) {
        showLinesView()
    }
}

// MARK: - CAAnimationDelegate

extension HomeViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let positions = selectedLine!.stations.map({ $0.location.toLocationCoordinate2D })
        
        mapView.drawPath(for: positions)
        
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
