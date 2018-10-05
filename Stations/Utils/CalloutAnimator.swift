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

class CalloutAnimator: NSObject {
    
    private let presenter: UIViewController
    private let mapView: GMSMapView
    private var callout: CalloutViewController!
    private var snapshot: UIView?
    
    // MARK: - Initializers
    
    init(presenter: UIViewController, mapView: GMSMapView) {
        self.presenter = presenter
        self.mapView = mapView
    }
    
    // MARK: - Public
    
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
