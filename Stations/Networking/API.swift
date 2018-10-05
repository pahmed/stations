//
//  API.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation
import Alamofire

/// This class represents the network access layer.
/// Any HTTP request should happen through an object of this class
class API {
    static let shared = API()
    
    /// Request the list of lines available
    ///
    /// - Parameter completion: A closure to be called on finishing the request
    /// with either a success associated with the LinesResponse or failure associated with
    /// the APIError
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
    
    /// Bookmark a station
    ///
    /// - Parameters:
    ///   - id: The id for the station to be bookmarked
    ///   - completion: A closure to be called on finishing the request
    /// with either a success or failure associated with the APIError
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
