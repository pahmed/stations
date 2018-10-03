//
//  HomePresenter.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation

protocol HomePresentationLogic {
}

class HomePresenter: HomePresentationLogic {
    
    let displayer: HomeDisplayLogic
    
    init(displayer: HomeDisplayLogic) {
        self.displayer = displayer
    }
    
}
