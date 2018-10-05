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

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var linesBottomConstraint: NSLayoutConstraint!
    private var mapView: GMSMapView!
    private var disposeBag = DisposeBag()
    
    private lazy var mapViewContentDrawer: MapViewContentDrawer = {
       let drawer = MapViewContentDrawer(mapView: mapView)
        return drawer
    }()
    
    private lazy var calloutAnimator: CalloutAnimator = {
        let animator = CalloutAnimator(presenter: self, mapView: mapView)
        return animator
    }()
    
    private var selectedLine: Line?
    private lazy var loadingView: LoadingView = LoadingView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoading()
    }
    
    func showLoading() {
        loadingView.show(in: self.view)
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Private
    
    private func setupMapView() {
        mapView = GMSMapView(frame: CGRect.zero)
        mapView.isMyLocationEnabled = true
        mapView.settings.setAllGesturesEnabled(false)
        mapView.settings.myLocationButton = true
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(mapView, at: 0)
        
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        mapView.delegate = self
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

// MARK: - GMSMapViewDelegate

extension HomeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // `marker.userData` could be nil if the marker e.g. is for bus
        guard let station = marker.userData as? Station else {
            return false
        }
        
        let point = mapView.projection.point(for: marker.position)
        
        calloutAnimator.presentCallout(from: point, for: station)
        return true
    }
    
}

// MARK: - LinesViewControllerDelegate

extension HomeViewController: LinesViewControllerDelegate {
    func linesViewController(_ linesViewController: LinesViewController, didSelect line: Line) {
        selectedLine = line
        mapViewContentDrawer.draw(stations: line.stations)
    }
    
    func linesViewController(_ linesViewController: LinesViewController, didLoad lines: [Line]) {
        if let line = lines.last {
            let positions = line.stations.map({ $0.location.toLocationCoordinate2D })
            mapViewContentDrawer.focusMapCamera(on: positions, animated: false)
        }
        loadingView.hide(completion: showLinesView)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

// This is important to be there to enable showing Popover on iPhone
// EVEN WHEN EMPTY
extension HomeViewController: UIPopoverPresentationControllerDelegate {
    
}
