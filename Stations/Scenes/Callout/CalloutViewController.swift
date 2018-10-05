//
//  CalloutViewController.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit
import Kingfisher

/// A view controller that represents the station callout
class CalloutViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private var station: Station!
    
    var handleTap: (() -> ())?
    
    // MARK: - Initializers
    
    class func calloutWith(station: Station) -> CalloutViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "CalloutViewController") as! CalloutViewController
        vc.station = station
        
        return vc
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindModelToView()
    }
    
    // MARK: - Events
    
    @IBAction func tapAction(_ sender: Any) {
        handleTap?()
    }
    
    // MARK: - Private
    
    private func bindModelToView() {
        nameLabel.text = station.name
        addressLabel.text = station.address
        imageView.kf.setImage(with: station.imageURL)
    }
}
