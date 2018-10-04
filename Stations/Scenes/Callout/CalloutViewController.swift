//
//  CalloutViewController.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit
import Kingfisher

final class CalloutViewController: UIViewController {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    private var name: String!
    private var address: String!
    private var imageURL: URL?
    
    var handleTap: (() -> ())?
    
    class func calloutWith(name: String, address: String, imageURL: URL?) -> CalloutViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "CalloutViewController") as! CalloutViewController
        vc.name = name
        vc.address = address
        vc.imageURL = imageURL
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindModelToView()
    }
    
    private func bindModelToView() {
        nameLabel.text = name
        addressLabel.text = address
        imageView.kf.setImage(with: imageURL)
    }
    
    @IBAction func tapAction(_ sender: Any) {
        handleTap?()
    }
}
