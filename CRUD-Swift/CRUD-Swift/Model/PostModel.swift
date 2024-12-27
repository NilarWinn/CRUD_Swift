//
//  ResponseType.swift
//  Bulletin-Board-Swift
//
//  Created by NilarWin on 25/10/2022.
//

import Foundation
struct PostModel : Decodable {
    let status: String?
    let message: String?
    var data: [Post]? = [] 
    enum CokingKeys: String, CodingKey {
        case status
        case message
    }
}

struct Post: Decodable {
    let id: String?
    let title: String?
    let description: String?
    let status: String?
    var posted_by: CreatedBy
    enum CokingKeys: String, CodingKey {
        case id
        case title
        case description
        case status
    }
}

struct CreatedBy: Decodable {
    var name: String?
    var type: String?
}
