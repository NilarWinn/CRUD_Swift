//
//  UserModel.swift
//  MVC-Swift
//
//  Created by NilarWin on 17/08/2022.
//

import Foundation

struct ResponseUserModel : Decodable {
    let status: String?
    let message: String?
    var data: [User]? = []
    enum CokingKeys: String, CodingKey {
        case status
        case message
    }
}

struct User: Decodable {
    let _id: String?
    let name: String?
    let email: String?
    let password: String?
    let profile : String?
    let type : String?
    let phone: String?
    let address: String?
    let dob: String?
    let create_user_id: Int?
    enum CokingKeys: String, CodingKey {
        case _id
        case name
        case email
        case password
        case profile
        case type
        case phone
        case address
        case dob
        case create_user_id
    }
}
