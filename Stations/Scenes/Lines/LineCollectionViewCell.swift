//
//  LineCollectionViewCell.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit

class LineCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configureWith(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
