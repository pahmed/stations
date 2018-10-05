//
//  StationDetailsViewController.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit
import Kingfisher

/// A protocol the defines the display logic abilities for a displayer.
/// A displayer is responsible for displaying the view models it gets from
/// a presenter, also responsible for passing the user events in form of command
/// to the interactor to run the business logic
protocol StationDetailsDisplayLogic {
    
    /// Displays an alert with the given title and message
    ///
    /// - Parameters:
    ///   - title: The alert title
    ///   - message: The alert body
    func displayAlert(title: String, message: String)
}

class StationDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    var handleDismiss: ((StationDetailsViewController) -> ())?
    
    lazy var interactor: StationDetailsBusinessLogic = {
        return StationDetailsInteractor(presenter: StationDetailsPresenter(displayer: self))
    }()
    
    private var station: Station!
    
    // MARK: - Initializers
    
    class func controllerWith(station: Station) -> StationDetailsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "StationDetailsViewController") as! StationDetailsViewController
        
        vc.station = station
        
        return vc
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        set(isLoading: false)
        bindModelToView()
    }
    
    // MARK: - Events
    
    @IBAction func handleBookmark(_ sender: Any) {
        set(isLoading: true)
        interactor.bookmark(station: station)
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
    
    private func set(isLoading: Bool) {
        let title = isLoading ? nil : NSLocalizedString("Bookmark", comment: "")
        bookmarkButton.setTitle(title, for: .normal)
        bookmarkButton.setLoadingIndicator(visibile: isLoading)
        bookmarkButton.isEnabled = (isLoading == false)
    }
    
}

// MARK: - Display Logic

extension StationDetailsViewController: StationDetailsDisplayLogic {
    func displayAlert(title: String, message: String) {
        set(isLoading: false)
        Alert(title: title, message: message)
            .addCancelAction()
            .show(in: self)
    }
}
