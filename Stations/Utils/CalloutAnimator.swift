//
//  CalloutAnimator.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/5/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit
import GoogleMaps
import Hero

/// A class that is responsible for presenting the station callout that appears when a user
/// taps on a station marker.
/// The class is also responsible for the transition animation from the callout to the StationDetails
class CalloutAnimator: NSObject {
    
    /// The presenter where the callout is presented on
    private let presenter: UIViewController
    
    /// A GMSMapView that acts as the source view for the popover, this is important in order to make
    /// sure the popover is rendered in the correct position
    private let mapView: GMSMapView
    
    /// The callout to be presented in the popover
    private var callout: CalloutViewController!
    
    /// A temp view that represents a snapshot from the callout popover.
    /// This is used to make the animation from the callout to the StationDetails
    private var snapshot: UIView?
    
    // MARK: - Initializers
    
    init(presenter: UIViewController, mapView: GMSMapView) {
        self.presenter = presenter
        self.mapView = mapView
    }
    
    // MARK: - Public
    
    /// Presents a popover callout at a given position on the map, containing the station details
    ///
    /// - Parameters:
    ///   - point: The point at which the popover callout should be drawn
    ///   - station: The station where its info to appear on the callout
    ///   - animated: A flag that indicates weather the presentation should be with animation or not
    ///   - completion: A closure to be called after presenting the callout
    func presentCallout(from point: CGPoint, for station: Station, animated: Bool = true, completion: (() -> Void)? = nil) {
        callout = CalloutViewController.calloutWith(station: station)
        callout.modalPresentationStyle = .popover
        
        let handleDismissDetails = { [weak self] (vc: StationDetailsViewController) in
            vc.dismiss(animated: true)
            self?.presentCallout(from: point, for: station, animated: false) {
                self?.snapshot!.removeFromSuperview()
            }
        }
        
        callout.handleTap = { [weak self] in
            self?.renderCalloutSnapshot()
            
            let detailsVC = StationDetailsViewController.controllerWith(station: station)
            detailsVC.handleDismiss = handleDismissDetails
            
            self?.callout.dismiss(animated: false)
            self?.presenter.present(detailsVC, animated: true)
        }
        
        let popover = callout.popoverPresentationController!
        configure(popover: popover, source: point)
        presenter.present(callout, animated: animated, completion: completion)
    }
    
    // MARK: - Private
    
    private func configure(popover: UIPopoverPresentationController, source point: CGPoint) {
        popover.delegate = presenter as? UIPopoverPresentationControllerDelegate
        let rect = CGRect(origin: point, size: CGSize.zero).inset(by: UIEdgeInsets(all: 15))
        
        popover.permittedArrowDirections = [.down]
        popover.sourceView = mapView
        popover.sourceRect = rect
    }
    
    private func renderCalloutSnapshot() {
        snapshot?.removeFromSuperview()
        snapshot = snapshotFor(callout: callout, in: presenter.view)
        presenter.view.addSubview(snapshot!)
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
    
}
