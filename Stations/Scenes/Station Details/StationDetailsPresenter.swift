//
//  StationDetailsPresenter.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation

/// A protocol that defines the presentation logic abilities for a presenter.
/// A presenter is responsible for receiving raw model objects from an interactor,
/// generate view models, then pass it to the displayer to be displayed
protocol StationDetailsPresentationLogic {
    
    /// Generate view model for the presented message in case of success
    func presentSuccessfullBookmark()
    
    /// Generate view model for the presented message in case of error
    func present(error: Error)
}

class StationDetailsPresenter: StationDetailsPresentationLogic {
    let displayer: StationDetailsDisplayLogic
    
    // MARK: - Initializers
    
    init(displayer: StationDetailsDisplayLogic) {
        self.displayer = displayer
    }
    
    // MARK: - Presentation Logic
    
    func presentSuccessfullBookmark() {
        displayer.displayAlert(
            title: NSLocalizedString("Bookmarked!", comment: ""),
            message: NSLocalizedString("Place has been successfully bookmarked", comment: "")
        )
    }
    
    func present(error: Error) {
        displayer.displayAlert(
            title: NSLocalizedString("Oops!", comment: ""),
            message: NSLocalizedString("Something went wrong, please try again later", comment: "")
        )
    }
}
