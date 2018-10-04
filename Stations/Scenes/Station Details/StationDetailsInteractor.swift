//
//  StationDetailsInteractor.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/4/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation

protocol StationDetailsBusinessLogic {
    func bookmark(station: Station)
}

class StationDetailsInteractor: StationDetailsBusinessLogic {
    
    let presenter: StationDetailsPresentationLogic
    
    init(presenter: StationDetailsPresentationLogic) {
        self.presenter = presenter
    }
    
    // MARK: - Business logic
    
    func bookmark(station: Station) {
        API.shared.bookmarkStation(id: station.id) { [weak self] (result) in
            switch result {
            case .success:
                self?.presenter.presentSuccessfullBookmark()
                
            case .failure(let error):
                self?.presenter.present(error: error)
            }
        }
    }
}
