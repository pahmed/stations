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
        let point = mapView.projection.point(for: marker.position)
        
        let station = marker.userData as! Station
        
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
    
    func linesViewControllerDidLoadLines(_ linesViewController: LinesViewController) {
        loadingView.hide(completion: showLinesView)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension HomeViewController: UIPopoverPresentationControllerDelegate {
    
}
