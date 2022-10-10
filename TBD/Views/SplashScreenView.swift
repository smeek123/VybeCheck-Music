//
//  SplashScreenView.swift
//  TBD
//
//  Created by Sean P. Meek on 6/29/22.
//

import SwiftUI
import CryptoKit

struct SplashScreenView: View {
    @State private var isActive: Bool = false
    @State private var size: Double = 1.0
    @State private var opacity: Double = 1.0
    @State private var rotate: Double = 0.0
    @AppStorage("onboardCompleted") var onboardComplete: Bool = false
    @AppStorage("signedIn") var isSignedIn: Bool = false
    @StateObject var spotifyData = SpotifyDataManager()
    @StateObject var spotify = SpotifyAuthManager()
    
    let gradient = LinearGradient(colors: [Color("MainColor"), Color(uiColor: .systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    let spotifyGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)), Color(#colorLiteral(red: 0.1903857588, green: 0.8321116255, blue: 0.4365008013, alpha: 1))]
        ),
        startPoint: .leading, endPoint: .trailing
    )
    
    var body: some View {
        if !isActive {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                Image("Logo")
                    .resizable()
                    .scaleEffect(size)
                    .opacity(opacity)
                    .rotationEffect(Angle(degrees: rotate))
                    .frame(width: 200, height: 200)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.3)) {
                            self.size = 10.0
                            self.opacity = 0.0
                            self.rotate = 180.0
                        }
                    }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        } else {
            if onboardComplete {
                ContentView()
            } else {
                onboard
            }
        }
    }
    
    var onboard: some View {
        ZStack {
            gradient
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack {
                    Image("Logo")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding()
                    
                    Text("Connecting a streaming service account will allow music recommendations to be made. This also provides the ability to play songs directly in your preferred streaming service. \n \n By continuing, you agree to the VybeCheck terms of use and privacy policy shown below.")
                        .font(.headline)               
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.vertical)
                    
                    Link(destination: URL(string: "spotify.com")!) {
                        HStack {
                            Text("View our Terms of Use")
                            
                            Spacer()
                        }
                        .padding(8)
                        .foregroundColor(Color("MainColor"))
                        .frame(width: UIScreen.main.bounds.width * 0.95)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(15)
                        .font(.headline)
                        .padding(2)
                    }
                    
                    Link(destination: URL(string: "spotify.com")!) {
                        HStack {
                            Text("View our Privacy Policy")
                                
                            Spacer()
                        }
                        .padding(8)
                        .foregroundColor(Color("MainColor"))
                        .frame(width: UIScreen.main.bounds.width * 0.95)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(15)
                        .font(.headline)
                        .padding()
                    }
                    
                    if SpotifyAM.isRetrievingTokens {
                        VStack {
                            VStack {
                                Text("Loading")
                                    .font(.largeTitle)
                                    .foregroundColor(.primary)
                                
                                ProgressView()
                                    .font(.largeTitle)
                                    .foregroundColor(.primary)
                            }
                        }
                    } else {
                        if isSignedIn {
                            VStack {
                                Button {
                                    onboardComplete = true
                                    
                                    HapticViewModel.instance.notification(type: .success)
                                } label: {
                                    Text("Continue")
                                        .padding(8)
                                        .foregroundColor(Color("MainColor"))
                                        .frame(width: UIScreen.main.bounds.width * 0.95)
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(15)
                                        .font(.headline)
                                        .padding()
                                }
                            }
                        } else {
                            Link(destination: spotify.spotifyURL()) {
                                HStack(spacing: 20) {
                                    Image("WhiteSpotifyIcon")
                                        .interpolation(.high)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 50)
                                    Text("Log in with Spotify")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                }
                                .background(RoundedRectangle(cornerRadius: 15)
                                    .fill(spotifyGradient)
                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.1))
                            }
                            .accessibility(identifier: "Log in with Spotify Identifier")
                            .padding(.vertical)
                            .allowsHitTesting(!SpotifyAM.isRetrievingTokens)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .onOpenURL { url in
            Task {
                await spotify.HandleURLCode(url)
            }
        }
    }
}
