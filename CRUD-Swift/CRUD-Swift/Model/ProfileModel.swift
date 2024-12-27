//
//  ProfileModel.swift
//  Bulletin-Board-Swift
//
//  Created by NilarWin on 25/10/2022.
//

import Foundation

struct ProfileModel : Decodable {
    let status: String?
    let message: String?
    var data: User?
    enum CokingKeys: String, CodingKey {
        case status
        case message
    }
}
