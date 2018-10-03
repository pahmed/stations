//
//  API.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation
import Alamofire

class API {
    static let shared = API()
    
    func lines(completion: @escaping (Result<LinesResponse, APIError>) -> Void) {
        let url = "http://private-ab8af-swvl.apiary-mock.com/lines"
        Alamofire.request(url)
            .responseData(queue: DispatchQueue.main) { (data) in
                let response = data.flatMap({ try JSONDecoder().decode(LinesResponse.self, from: $0) })
                
                switch response.result {
                case .success(let linesResponse):
                    completion(.success(linesResponse))
                    
                case .failure:
                    completion(.failure(.mapping))
                }
        }
    }
}
