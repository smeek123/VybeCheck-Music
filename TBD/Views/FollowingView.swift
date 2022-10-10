//
//  FollowingView.swift
//  TBD
//
//  Created by Sean P. Meek on 4/21/22.
//

import SwiftUI

struct FollowingView: View {
    @StateObject var spotifyData = SpotifyDataManager()
    @AppStorage("onboardCompleted") var onboardComplete: Bool = false
    
    let gradient = LinearGradient(colors: [Color("MainColor"), Color(uiColor: .systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        NavigationView {
            ZStack {
                gradient
                    .ignoresSafeArea(.all)
                
                Grid(horizontalSpacing: 45, verticalSpacing: 45) {
                    GridRow {
                        vybeOption(option: VybeOptionModel(title: "angry", color: "AngryColor", minEnergy: 0.55, maxEnergy: 1, minTempo: 105, maxTempo: 300, minValence: 0, maxValence: 0.45, minDance: 0.55, maxDance: 1))
                        
                        vybeOption(option: VybeOptionModel(title: "hype", color: "HypeColor", minEnergy: 0.55, maxEnergy: 1, minTempo: 110, maxTempo: 300, minValence: 0, maxValence: 1, minDance: 0.5, maxDance: 1))
                    }
                    
                    GridRow {
                        vybeOption(option: VybeOptionModel(title: "sad", color: "SadColor", minEnergy: 0, maxEnergy: 0.7, minTempo: 70, maxTempo: 155, minValence: 0.0, maxValence: 0.35, minDance: 0.37, maxDance: 0.7))
                        
                        vybeOption(option: VybeOptionModel(title: "energetic", color: "AnxiousColor", minEnergy: 0.75, maxEnergy: 1, minTempo: 0, maxTempo: 300, minValence: 0, maxValence: 1, minDance: 0, maxDance: 1))
                    }
                    
                    GridRow {
                        vybeOption(option: VybeOptionModel(title: "carefree", color: "HappyColor", minEnergy: 0, maxEnergy: 0.4, minTempo: 0, maxTempo: 300, minValence: 0.6, maxValence: 1, minDance: 0, maxDance: 1))
                        
                        vybeOption(option: VybeOptionModel(title: "chill", color: "CalmColor", minEnergy: 0.35, maxEnergy: 0.8, minTempo: 0, maxTempo: 300, minValence: 0, maxValence: 1, minDance: 0.5, maxDance: 1))
                    }
                }
            }
            .navigationTitle("Vybes")
            .task {
                if UserView.favArtists == "" {
                    _ = try? await spotifyData.getTopArtist()
                }
            }
        }
        .accentColor(.primary)
    }
}

