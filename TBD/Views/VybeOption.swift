//
//  VybeOption.swift
//  TBD
//
//  Created by Sean P. Meek on 6/20/22.
//

import SwiftUI

struct vybeOption: View {
    let option: VybeOptionModel
    @AppStorage("signedIn") var isSignedIn: Bool = false
    @State var recommendedTracks: recommendation? = nil
    @State var recommendedTrack: track? = nil
    @StateObject var spotifyData = SpotifyDataManager()
    @State var showSignIn: Bool = false
    
    func loadTrack() {
        Task {
            recommendedTracks = await spotifyData.getRecomended(minEnergy: option.minEnergy, maxEnergy: option.maxEnergy, minTempo: option.minTempo, maxTempo: option.maxTempo, minValence: option.minValence, maxValence: option.maxValence, minDance: option.minDance, maxDance: option.maxDance)
            
            await MainActor.run {
                recommendedTrack = recommendedTracks?.tracks.first
                
                print(recommendedTrack ?? "Empty track")
            }
        }
    }
    
    var body: some View {
        VStack {
            Button {
                if isSignedIn {
                    print(option.title)
                    
                    loadTrack()
                    
                    if recommendedTrack == nil {
                        HapticViewModel.instance.notification(type: .error)
                    } else {
                        HapticViewModel.instance.notification(type: .success)
                    }
                } else {
                    showSignIn = true
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(option.color))
                        .shadow(color: .black, radius: 5)
                        .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.width * 0.4)
                    
                    if spotifyData.isRetrievingData {
                        ProgressView()
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                    } else {
                        Text(option.title.uppercased())
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                    }
                }
            }
        }
        .alert("Please add a music streaming account!", isPresented: $showSignIn) {
            Button(role: .cancel) {
                print("")
            } label: {
                Text("Ok")
            }
        }
        .sheet(item: $recommendedTrack) { track in
            RecommendedTrackView(vybe: option.title, track: track)
        }
    }
}
