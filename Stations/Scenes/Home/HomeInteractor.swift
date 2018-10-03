//
//  HomeInteractor.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation
import Alamofire

protocol HomeBusinessLogic {

}

class HomeInteractor: HomeBusinessLogic {
    
    let presenter: HomePresentationLogic
    
    init(presenter: HomePresentationLogic) {
        self.presenter = presenter
    }
    
    // MARK: - BusinessLogic
}
