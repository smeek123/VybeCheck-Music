//
//  AuthResponse.swift
//  TBD
//
//  Created by Sean P. Meek on 5/30/22.
//

import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let expires_in: Int
    let refresh_token: String?
}
