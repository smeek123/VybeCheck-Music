//
//  UserModel.swift
//  TBD
//
//  Created by Sean P. Meek on 6/11/22.
//

import Foundation

struct UserModel: Codable {
    let country: String
    let display_name: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    let id: String
    let product: String
    let uri: String
    let images: [APIImage]?
}

struct APIImage: Codable {
    let url: String
}
