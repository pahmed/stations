//
//  Alert.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit

class Alert {
    
    /// A reference to the alert to be presented
    let alert: UIAlertController
    
    /// An initializer for creating an alert, with optional title and message
    ///
    /// - Parameters:
    ///   - title: The title that should appear on the alert
    ///   - message: The body of the alert
    init(title: String? = nil, message: String? = nil) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    /// Adds an action button to the alert
    ///
    /// - Parameter action: An action that can be taken when the user taps a button in an alert
    /// - Returns: The alert itself, for achieving chainable methods, this is useful if you need to add nultiple actions inline
    func add(action: UIAlertAction) -> Self {
        alert.addAction(action)
        return self
    }
    
    /// A convenience method for adding a cancel button
    ///
    /// - Parameter title: An optional title for the action, allows customizing the title of the button, the default is `Cancel`
    /// - Returns: The alert itself, for achieving chainable methods, this is useful if you need to add nultiple actions inline
    func addCancelAction(title: String = NSLocalizedString("Cancel", comment: "")) -> Self {
        alert.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
        return self
    }
    
    /// Presents the alert in a given UIViewController
    ///
    /// - Parameter vc: An optional UIViewController where the alert should be presented, the default of this is the `rootViewController` of the `keyWindow`
    func show(in vc: UIViewController? = nil) {
        let vc = vc ?? UIApplication.shared.keyWindow!.rootViewController!
        
        vc.present(alert, animated: true, completion: nil)
    }
}
