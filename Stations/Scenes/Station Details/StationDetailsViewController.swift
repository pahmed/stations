//
//  StationDetailsViewController.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit
import Kingfisher

class StationDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var handleDismiss: ((StationDetailsViewController) -> ())?
    
    private var station: Station!
    
    class func controllerWith(station: Station) -> StationDetailsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "StationDetailsViewController") as! StationDetailsViewController
        
        vc.station = station
        
        return vc
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindModelToView()
    }
    
    // MARK: - Events
    
    @IBAction func handleBookmark(_ sender: Any) {
        
    }
    
    @IBAction func handleDismiss(_ sender: Any) {
        if let handleDismiss = handleDismiss {
            handleDismiss(self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Private
    
    private func bindModelToView() {
        imageView.kf.setImage(with: station.imageURL)
        nameLabel.text = station.name
        addressLabel.text = station.address
    }
    
}
