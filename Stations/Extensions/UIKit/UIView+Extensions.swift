//
//  UIView+Extensions.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Clones a UIView
    ///
    /// - Returns: A deep copy from this UIView
    func clone() -> UIView? {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIView
    }
}

extension UIView {
    
    /// A helper method that adds edges constraints that matches the super view
    ///
    /// - Parameter view: The view where the edges constraints should match
    func matchEdgesConstraints(for view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
}
