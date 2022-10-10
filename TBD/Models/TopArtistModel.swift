//
//  TopArtistModel.swift
//  TBD
//
//  Created by Sean P. Meek on 6/16/22.
//

import Foundation

struct topArtistModel: Codable {
    let items: [artistItem]
}

struct artistItem: Codable {
    let images: [APIImage]?
    let name: String
    let uri: String
    let id: String
}

