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
        let request = self.request(
            for: "http://private-ab8af-swvl.apiary-mock.com/lines",
            method: .get
        )
        
        request.responseData(queue: DispatchQueue.main) { (data) in
            let response = data.flatMap({ try JSONDecoder().decode(LinesResponse.self, from: $0) })
            
            switch response.result {
            case .success(let linesResponse):
                completion(.success(linesResponse))
                
            case .failure:
                completion(.failure(.mapping))
            }
        }
    }
    
    func bookmarkStation(id: Int, completion: @escaping (Result<Void, APIError>) -> Void) {
        let request = self.request(
            for: "http://private-ab8af-swvl.apiary-mock.com/station/\(id)/bookmark",
            method: .post
        )
        
        request.responseJSON() { (response) in
            switch response.result {
            case .success:
                completion(.success(()))
                
            case .failure:
                completion(.failure(.unknown))
            }
        }
    }
    
    private func request(for url: String, method: HTTPMethod) -> DataRequest {
        return Alamofire
            .request(url, method: method)
            .validate(statusCode: 200..<300)
    }
}
