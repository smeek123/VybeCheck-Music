//
//  SpotifyViewModel.swift
//  TBD
//
//  Created by Sean P. Meek on 5/14/22.
//

import Foundation
import SwiftUI
import CryptoKit
import Security

struct SpotifyAM {
    @State static var isRetrievingTokens: Bool = false
    @AppStorage("signedIn") static var isSignedIn: Bool = false
    @AppStorage("expiresAt") static var expiresAt: Date = Date()
    static let client_id: String = "0865cb10d9044ca0b9065da93f53cb1f"
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case noPassword
    }
    
    static func updateTokens(service: String, accounr: String, authData: Data) async throws {
        let query: [String: AnyObject] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service as AnyObject, kSecAttrAccount as String: accounr as AnyObject]
        
        let attrubutes: [String: AnyObject] = [kSecValueData as String: authData as AnyObject]
        
        let status = SecItemUpdate(query as CFDictionary, attrubutes as CFDictionary)
        
        guard status != errSecItemNotFound else {
            print("notFound")
            throw KeychainError.noPassword
        }
        
        guard status == errSecSuccess else {
            print("unkown update error")
            throw KeychainError.unknown(status)
        }
        
        await MainActor.run {
            SpotifyAM.isSignedIn = true
        }
        
        print(SpotifyAM.isSignedIn)
        print("updated")
    }
}

class SpotifyAuthManager: ObservableObject {
    let client_secret: String = "b5024ee2fa1541368a68799a80628f00"
    let redirect_uriURL: URL = URL(string: "vybecheck-app://login-callback")!
    let scopes: String = "user-modify-playback-state%20user-top-read%20user-read-private"
    var inputState: String = ""
    var returnState: String = ""
    var returnCode: String = ""
    var returnError: String = ""
    var code_challenge: String = ""
    var code_verifier: String = ""
    
    static var shouldRefresh: Bool {
        guard SpotifyAM.expiresAt <= Date().addingTimeInterval(300) else {
            return false
        }
        guard SpotifyAM.isRetrievingTokens == false else {
            return false
        }
        return true
    }
    
    static func withCurrentToken() async -> String {
        var accessToken: String = ""
        do {
            if shouldRefresh {
                try await getRefreshedAccessToken()
            }
            
            guard let refreshData = try? getTokens(service: "spotify.com", account: "accessToken") else {
                throw URLError(.dataNotAllowed)
            }
            
            accessToken = String(decoding: refreshData, as: UTF8.self)
            return accessToken
        } catch {
            print(error.localizedDescription)
        }
        
        return accessToken
    }
    
    enum PKCEError: Error {
        case failedToGenerateRandomOctets
        case failedToCreateChallengeForVerifier
    }
    
    func randomString(length: Int) -> String {
        let chars: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.-~"
        return String((0..<length).map{ _ in chars.randomElement()! })
    }
    
    func generateCryptographicallySecureRandomOctets(count: Int) throws -> [UInt8] {
        var octets = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, octets.count, &octets)
        if status == errSecSuccess { // Always test the status.
            return octets
        } else {
            throw PKCEError.failedToGenerateRandomOctets
        }
    }
    
    func base64URLEncode<S>(octets: S) -> String where S : Sequence, UInt8 == S.Element {
        let data = Data(octets)
        return data
            .base64EncodedString() // Regular base64 encoder
            .replacingOccurrences(of: "=", with: "") // Remove any trailing '='s
            .replacingOccurrences(of: "+", with: "-") // 62nd char of encoding
            .replacingOccurrences(of: "/", with: "_") // 63rd char of encoding
            .trimmingCharacters(in: .whitespaces)
    }
    
    func challenge(for verifier: String) throws -> String {
        let challenge = verifier
            .data(using: .ascii) // (a)
            .map { SHA256.hash(data: $0) } // (b)
            .map { base64URLEncode(octets: $0) } // (c)

        if let challenge = challenge {
            return challenge
        } else {
            throw PKCEError.failedToCreateChallengeForVerifier
        }
    }
    
    func spotifyURL() -> URL {
        do {
            code_verifier = try base64URLEncode(octets: generateCryptographicallySecureRandomOctets(count: 32))
            code_challenge = try challenge(for: code_verifier)
        } catch {
            print(error.localizedDescription)
        }
        
        guard let spotifyURL: URL = URL(string: "https://accounts.spotify.com/authorize?response_type=code&client_id=\(SpotifyAM.client_id)&scope=\(scopes)&redirect_uri=\(redirect_uriURL.absoluteString)&state=\(inputState)&code_challenge_method=S256&code_challenge=\(String(describing: code_challenge))&show_dialog=TRUE") else {
            return URL(string: "https://google.com")!
        }
        return spotifyURL
    }
    
    func HandleURLCode(_ url: URL) async {
        SpotifyAM.isRetrievingTokens = true
        
        guard url.scheme == self.redirect_uriURL.scheme else {
            print("Invalid scheme")
            return
        }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        if let state = components?.queryItems?.first(where: { QueryItem -> Bool in
            QueryItem.name == "state"
        })?.value {
            returnState = state
        }
        
        if let code = components?.queryItems?.first(where: { QueryItem -> Bool in
            QueryItem.name == "code"
        })?.value {
            returnCode = code
        }
        
        if let error = components?.queryItems?.first(where: { QueryItem -> Bool in
            QueryItem.name == "error"
        })?.value {
            returnError = error
        }
        
        if returnState == inputState {
            if returnError == "" {
                try? await getAccessToken(accessCode: returnCode, code_verifier: code_verifier)
            } else {
                print(returnError)
            }
        }
    }
    
    func getAccessToken(accessCode: String, code_verifier: String) async throws {
        let api_auth_key: String = "Basic \((SpotifyAM.client_id + ":" + client_secret).data(using: .utf8)!.base64EncodedString())"
        
        let requestHeaders: [String: String] = ["authorization" : api_auth_key, "Content-Type" : "application/x-www-form-urlencoded"]
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "grant_type", value: "authorization_code"), URLQueryItem(name: "client_id", value: SpotifyAM.client_id), URLQueryItem(name: "code", value: accessCode), URLQueryItem(name: "redirect_uri", value: redirect_uriURL.absoluteString), URLQueryItem(name: "code_verifier", value: code_verifier)]
        
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        do {
            guard let data = requestBodyComponents.query?.data(using: .utf8) else {
                throw URLError(.dataNotAllowed)
            }
            
            let (responseData, response) = try await
            URLSession.shared.upload(for: request, from: data)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                fatalError("error with fetching data")
            }
            
            let result = try JSONDecoder().decode(AuthResponse.self, from: responseData)
            
            try await saveToKeychain(service: "spotify.com", account: "accessToken", authData: result.access_token.data(using: .utf8) ?? Data())
            
            guard let refreshToken = result.refresh_token else {
                return
            }
            
            try await saveToKeychain(service: "spotify.com", account: "refreshToken", authData: refreshToken.data(using: .utf8) ?? Data())
            
            await MainActor.run {
                SpotifyAM.expiresAt = Date().addingTimeInterval(TimeInterval(result.expires_in))
                
                SpotifyAM.isSignedIn = true
            }
        } catch {
            print(error.localizedDescription)
        }
        
        await MainActor.run {
            SpotifyAM.isRetrievingTokens = false
        }
    }
    
    // 1. saveauth data to keychain
    func saveToKeychain(service: String, account: String, authData: Data) async throws {
        let query: [String: AnyObject] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service as AnyObject, kSecAttrAccount as String: account as AnyObject, kSecValueData as String: authData as AnyObject]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            try? await SpotifyAM.updateTokens(service: service, accounr: account, authData: authData)
            print("duplicate")
            throw SpotifyAM.KeychainError.duplicateEntry
        } else {
            print("success")
        }
        
        if status != errSecSuccess {
            throw SpotifyAM.KeychainError.unknown(status)
        } else {
            print("success")
        }
        
        print("saved")
    }
    
    // 2. request new access_token
    static func getRefreshedAccessToken() async throws {
        let requestHeaders: [String: String] = ["Content-Type": "application/x-www-form-urlencoded"]
        
        guard let refreshData = try? getTokens(service: "spotify.com", account: "refreshToken") else {
            throw URLError(.dataNotAllowed)
        }
        
        let refreshToken = String(decoding: refreshData, as: UTF8.self)
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token"), URLQueryItem(name: "client_id", value: SpotifyAM.client_id), URLQueryItem(name: "refresh_token", value: refreshToken)]
        
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        do {
            guard let data = requestBodyComponents.query?.data(using: .utf8) else {
                throw URLError(.dataNotAllowed)
            }
            
            let (responseData, _) = try await
            URLSession.shared.upload(for: request, from: data)
            
            let result = try JSONDecoder().decode(AuthResponse.self, from: responseData)
            
            try await SpotifyAM.updateTokens(service: "spotify.com", accounr: "accessToken", authData: result.access_token.data(using: .utf8) ?? Data())
            
            guard let refreshToken = result.refresh_token else {
                return
            }
            
            try await SpotifyAM.updateTokens(service: "spotify.com", accounr: "refreshToken", authData: refreshToken.data(using: .utf8) ?? Data())
            
            print("refreshed")
            
            await MainActor.run(body: {
                SpotifyAM.expiresAt = Date().addingTimeInterval(TimeInterval(result.expires_in))
                
                SpotifyAM.isSignedIn = true
            })
        } catch {
            print("error getting data")
            print(error.localizedDescription)
        }
    }
    
    //read the refresh token and put it into call qhich should be after 3000 secconds from start of expired_in value
    
    static func getTokens(service: String, account: String) throws -> Data? {
        let query: [String: AnyObject] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service as AnyObject, kSecAttrAccount as String: account as AnyObject, kSecReturnData as String: kCFBooleanTrue, kSecMatchLimit as String: kSecMatchLimitOne]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            print("notFound2")
            throw SpotifyAM.KeychainError.noPassword
        }
        
        guard status == errSecSuccess else {
            print("unkown match error")
            throw SpotifyAM.KeychainError.unknown(status)
        }
        
        return result as? Data
    }
    
    static func deleteToken(service: String, accounr: String) async throws {
        let query: [String: AnyObject] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service as AnyObject, kSecAttrAccount as String: accounr as AnyObject]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status != errSecItemNotFound else {
            print("notFound")
            throw SpotifyAM.KeychainError.noPassword
        }
        
        guard status == errSecSuccess else {
            print("unkown delete error")
            throw SpotifyAM.KeychainError.unknown(status)
        }
        
        await MainActor.run {
            SpotifyAM.isSignedIn = false
        }
    }
}
