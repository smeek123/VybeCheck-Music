//
//  SpotifyDataManager.swift
//  TBD
//
//  Created by Sean P. Meek on 6/6/22.
//

import Foundation

struct Constants {
    static let baseURL: String = "https://api.spotify.com/v1"
}

class SpotifyDataManager: ObservableObject {
    @Published var isRetrievingData: Bool = false
    static var instance = SpotifyDataManager()
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    func createRequest(url: URL?, type: HTTPMethod) async throws -> URLRequest {
        let token = await SpotifyAuthManager.withCurrentToken()
        guard let url = url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = type.rawValue
        request.timeoutInterval = 30
        return request
    }
    
    func getProfile() async throws -> UserModel? {
        do {
            await MainActor.run {
                isRetrievingData = true
            }
            
            let profileRequest = try await createRequest(url: URL(string: Constants.baseURL + "/me"), type: .GET)
            
            let (data, response) = try await URLSession.shared.data(for: profileRequest)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                fatalError("error with fetching data")
            }
            
            let currentUser = try JSONDecoder().decode(UserModel.self, from: data)

            
            await MainActor.run {
                isRetrievingData = false
            }
            
            return currentUser
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getTopArtist() async throws -> topArtistModel? {
        do {
            await MainActor.run {
                isRetrievingData = true
            }
            
            let artistRequest = try await createRequest(url: URL(string: Constants.baseURL + "/me/top/artists?limit=5&time_range=short_term"), type: .GET)
            
            let (data, _) = try await URLSession.shared.data(for: artistRequest)
            
            let topArtist = try JSONDecoder().decode(topArtistModel.self, from: data)
            
            await MainActor.run {
                isRetrievingData = false
                
                UserView.favArtists = ""
                
                for item in topArtist.items {
                    UserView.favArtists += item.id
                    UserView.favArtists += ","
                }
            }
            
            return topArtist
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getTopTrack() async throws -> topTrackModel? {
        do {
            await MainActor.run {
                isRetrievingData = true
            }
            
            let trackRequest = try await createRequest(url: URL(string: Constants.baseURL + "/me/top/tracks?limit=10&time_range=short_term"), type: .GET)
            
            let (data, response) = try await URLSession.shared.data(for: trackRequest)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                fatalError("error with fetching data")
            }
            
            let topTrack = try JSONDecoder().decode(topTrackModel.self, from: data)
            
            await MainActor.run {
                isRetrievingData = false
            }
            
            return topTrack
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getRecomended(minEnergy: Double, maxEnergy: Double, minTempo: Double, maxTempo: Double, minValence: Double, maxValence: Double, minDance: Double, maxDance: Double) async -> recommendation? {
        do {
            await MainActor.run {
                isRetrievingData = true
            }
            
            let recommended = try await createRequest(url: URL(string: Constants.baseURL + "/recommendations?seed_artists=\(UserView.favArtists)&limit=1&min_energy=\(minEnergy)&max_energy=\(maxEnergy)&min_tempo=\(minTempo)&max_tempo=\(maxTempo)&min_valence=\(minValence)&max_valence=\(maxValence)&min_dance=\(minDance)&max_dance=\(maxDance)"), type: .GET)
            
            let (data, _) = try await URLSession.shared.data(for: recommended)
            
            let recommendation = try JSONDecoder().decode(recommendation.self, from: data)
            
            print(recommendation)
            
            await MainActor.run {
                isRetrievingData = false
            }
            
            return recommendation
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
