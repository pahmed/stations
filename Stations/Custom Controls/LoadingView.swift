//
//  LoadingView.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/5/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit

class LoadingView: UIVisualEffectView {
    
    func show(in view: UIView) {
        
        effect = UIBlurEffect(style: .regular)
        
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .darkGray
        indicator.startAnimating()
        
        contentView.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        self.matchEdgesConstraints(for: view)
    }
    
    func hide(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            completion?()
        })
    }
    
}
