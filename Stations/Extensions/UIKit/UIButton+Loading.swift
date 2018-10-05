//
//  UIButton+Loading.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit

/// An extension to UIButton that adds support for showing loading indicator
extension UIButton {
    
    private struct AssociatedKeys {
        static var activityIndicator: UInt8 = 0
    }
    
    private var activityIndicator: UIActivityIndicatorView {
        get {
            if let indicator = objc_getAssociatedObject(self, &AssociatedKeys.activityIndicator) as? UIActivityIndicatorView {
                return indicator
            } else {
                let indicator = setupActivityIndicatorView()
                objc_setAssociatedObject(self, &AssociatedKeys.activityIndicator, indicator, .OBJC_ASSOCIATION_RETAIN)
                return indicator
            }
        }
    }
    
    private var hasActivityIndicator: Bool {
        return (objc_getAssociatedObject(self, &AssociatedKeys.activityIndicator) as? UIActivityIndicatorView) != nil
    }
    
    func setLoadingIndicator(visibile: Bool) {
        if visibile {
            activityIndicator.startAnimating()
        } else if hasActivityIndicator {
            activityIndicator.stopAnimating()
        }
        
        // Otherwise do nothing, as there is no activity indicator added already
    }
    
    private func setupActivityIndicatorView() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.hidesWhenStopped = true
        
        addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        return indicator
    }
    
}
