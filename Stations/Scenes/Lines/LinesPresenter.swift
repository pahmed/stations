//
//  LinesPresenter.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation

protocol LinesPresentationLogic {
    func present(lines: [Line])
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
        
    }
}
