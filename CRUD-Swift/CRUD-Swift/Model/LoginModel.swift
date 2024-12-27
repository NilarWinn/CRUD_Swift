//
//  LoginModel.swift
//  Bulletin-Board-Swift
//
//  Created by NilarWin on 25/10/2022.
//

import Foundation

struct LoginModel : Decodable {
    let status: String?
    let token: String?
    let type: String?
    let name: String?
    let profile: String?
    let message: String?
    let error: String?
    enum CokingKeys: String, CodingKey {
        case status
        case token
        case type
        case name
        case profile
        case message
        case error
    }
}
