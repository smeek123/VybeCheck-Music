//
//  ContentView.swift
//  TBD
//
//  Created by Sean P. Meek on 4/15/22.
//

import SwiftUI

struct ContentView: View {
    @State private var tab: Int = 1
    @StateObject var spotify = SpotifyAuthManager()
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.4)
    }
    
    var body: some View {
        TabView(selection: $tab) {
            FollowingView().tabItem {
                Label("Vybes", systemImage: "face.dashed")
            }
            .tag(1)
            
            ProfileView().tabItem {
                Label("Accounts", systemImage: "headphones")
            }
            .tag(2)
        }
        .accentColor(Color("MainColor"))
        .task {
            if SpotifyAuthManager.shouldRefresh {
                try? await SpotifyAuthManager.getRefreshedAccessToken()
            }
        }
    }
}
