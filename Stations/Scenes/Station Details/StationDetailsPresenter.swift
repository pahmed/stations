//
//  StationDetailsPresenter.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation

protocol StationDetailsPresentationLogic {
    func presentSuccessfullBookmark()
    func present(error: Error)
}

class StationDetailsPresenter: StationDetailsPresentationLogic {
    let displayer: StationDetailsDisplayLogic
    
    init(displayer: StationDetailsDisplayLogic) {
        self.displayer = displayer
    }
    
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
