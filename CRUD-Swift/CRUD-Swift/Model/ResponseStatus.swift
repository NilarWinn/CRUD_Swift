//
//  ResponseStatus.swift
//  Bulletin-Board-Swift
//
//  Created by NilarWin on 25/10/2022.
//

import Foundation

struct ResponseStatus : Decodable {
    let status: String?
    let message: String?
    
    enum CokingKeys: String, CodingKey {
        case status
        case message
    }
}
