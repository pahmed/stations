//
//  LinesInteractor.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation
import Alamofire

protocol LinesBusinessLogic {
    func loadLines()
}

class LinesInteractor: LinesBusinessLogic {
    
    let presenter: LinesPresentationLogic
    
    init(presenter: LinesPresentationLogic) {
        self.presenter = presenter
    }
    
    func loadLines() {
        API.shared.lines { [weak self] (result) in
            switch result {
            case .success(let response):
                self?.presenter.present(lines: response.lines)
                
            case .failure(let error):
                self?.presenter.present(error: error)
            }
        }
    }
    
}
