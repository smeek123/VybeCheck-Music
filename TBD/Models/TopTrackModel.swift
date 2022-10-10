//
//  TopTrackModel.swift
//  TBD
//
//  Created by Sean P. Meek on 6/16/22.
//

import Foundation

struct topTrackModel: Codable {
    let items: [track]
}

struct album: Codable {
    let images: [APIImage]
}
