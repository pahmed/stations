//
//  LinesPresenter.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation

/// A protocol that defines the presentation logic abilities for a presenter.
/// A presenter is responsible for receiving raw model objects from an interactor,
/// generate view models, then pass it to the displayer to be displayed
protocol LinesPresentationLogic {
    
    /// Generate the view model (if needed) to be presented by the Displayer
    ///
    /// - Parameter lines: The list of lines to be presented
    func present(lines: [Line])
    
    /// Generates the view model for an error to be displayed by the Displayer
    ///
    /// - Parameter error: The raw error value to be presented
    func present(error: Error)
}

class LinesPresenter: LinesPresentationLogic {
    
    let displayer: LinesDisplayLogic
    
    init(displayer: LinesDisplayLogic) {
        self.displayer = displayer
    }
    
    func present(lines: [Line]) {
        displayer.display(lines: lines)
    }
    
    func present(error: Error) {
        displayer.displayAlert(
            title: NSLocalizedString("Oops!", comment: ""),
            message: NSLocalizedString("Something went wrong while loading the bus lines, please try again later", comment: "")
        )
    }
}
