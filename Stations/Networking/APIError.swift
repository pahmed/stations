//
//  APIError.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import Foundation

/// An enum that represents the list of errors that might happen
/// on performing an API request
///
/// - unknown: An enum case represents that case where the error is unknown
/// - mapping: An enum case represents that case where the error is happens while parsing the raw data in the store
enum APIError: Error {
    case unknown
    case mapping
}
