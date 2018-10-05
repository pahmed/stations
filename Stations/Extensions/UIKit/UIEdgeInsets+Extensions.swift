//
//  UIEdgeInsets+Extensions.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    /// Craetes an UIEdgeInsets value with equal insets.
    /// This is equivalent to passing the same values for top, left, bottom, and right
    ///
    /// - Parameter value: The insets value
    init(all value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}
