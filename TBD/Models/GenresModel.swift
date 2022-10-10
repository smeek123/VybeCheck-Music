//
//  GenresModel.swift
//  TBD
//
//  Created by Sean P. Meek on 6/18/22.
//

import Foundation

struct recommendation: Codable {
    let tracks: [track]
}

struct track: Codable, Identifiable {
    let album: album
    let artists: [artistItem]?
    let explicit: Bool?
    let id: String
    let name: String
    let uri: String
    let preview_url: String?
    let restrictions: Restriction?
    let external_urls: ExternalURL?
}

