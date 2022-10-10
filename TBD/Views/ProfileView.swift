//
//  ProfileView.swift
//  TBD
//
//  Created by Sean P. Meek on 4/19/22.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseRemoteConfigSwift
import GoogleMobileAds

struct ProfileView: View {
    @AppStorage("signedIn") var isSignedIn: Bool = false
    @State var currentUser: UserModel? = nil
    @State var showDelete: Bool = false
    @State var isExpanded: Bool = false
    @State var adUnit: String = "ca-app-pub-7042022413601168/9297968923"
    
    let spotifyGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)), Color(#colorLiteral(red: 0.1903857588, green: 0.8321116255, blue: 0.4365008013, alpha: 1))]
        ),
        startPoint: .leading, endPoint: .trailing
    )
    
    let gradient = LinearGradient(colors: [Color("MainColor"), Color(uiColor: .systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    @StateObject var spotify = SpotifyAuthManager()
    @StateObject var spotifyData = SpotifyDataManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                gradient
                    .ignoresSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        Text("Connecting a streaming service account will allow music recommendations to be made. This also provides the ability to play songs directly in your preferred streaming service.")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        //                        Button {
                        //
                        //                        } label:  {
                        //                            Image("AppleMusicBadge")
                        //                                .interpolation(.high)
                        //                                .resizable()
                        //                                .scaledToFit()
                        //                                .frame(width: UIScreen.main.bounds.width * 0.9)
                        //                        }
                        
                        if SpotifyAM.isRetrievingTokens {
                            VStack {
                                HStack {
                                    Image(systemName: "person.circle")
                                        .font(.system(size: 75))
                                        .foregroundColor(Color(UIColor.secondarySystemBackground))
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Username")
                                            .lineLimit(1)
                                            .foregroundColor(Color(UIColor.secondarySystemBackground))
                                            .font(.title)
                                        
                                        Text("Spotify")
                                            .font(.title2)
                                            .foregroundColor(Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)))
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                                    .frame(width: UIScreen.main.bounds.width * 0.95, height: 35)
                                    .padding(.horizontal)
                            }
                        } else {
                            if isSignedIn {
                                if spotifyData.isRetrievingData {
                                    VStack {
                                        HStack {
                                            Image(systemName: "person.circle")
                                                .font(.system(size: 75))
                                                .foregroundColor(Color(UIColor.secondarySystemBackground))
                                            
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text("Username")
                                                    .lineLimit(1)
                                                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                                                    .font(.title)
                                                
                                                Text("Spotify")
                                                    .font(.title2)
                                                    .foregroundColor(Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)))
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundColor(Color(UIColor.secondarySystemBackground))
                                            .frame(width: UIScreen.main.bounds.width * 0.95, height: 35)
                                            .padding(.horizontal)
                                    }
                                } else {
                                    VStack {
                                        if let user = currentUser {
                                            NavigationLink {
                                                UserView(userName: user.display_name, uri: user.uri, image: user.images?.first?.url)
                                            } label: {
                                                HStack {
                                                    if let image = user.images?.first?.url {
                                                        WebImage(url: URL(string: image) ?? URL(string: "")!)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 75, height: 75)
                                                            .clipShape(Circle())
                                                    } else {
                                                        Image(systemName: "person.circle")
                                                            .font(.system(size: 75))
                                                    }
                                                    
                                                    VStack(alignment: .leading, spacing: 0) {
                                                        Text(user.display_name)
                                                            .lineLimit(1)
                                                            .foregroundColor(.primary)
                                                            .font(.title)
                                                        
                                                        Text("Spotify")
                                                            .font(.title2)
                                                            .foregroundColor(Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)))
                                                    }
                                                    
                                                    Spacer()
                                                }
                                                .padding(.horizontal)
                                            }
                                        }
                                        
                                        Button {
                                            showDelete = true
                                            
                                            HapticViewModel.instance.impact(style: .light)
                                        } label: {
                                            Text("Remove Account")
                                                .padding(8)
                                                .foregroundColor(.red)
                                                .frame(width: UIScreen.main.bounds.width * 0.95)
                                                .background(Color(UIColor.systemBackground))
                                                .cornerRadius(15)
                                                .font(.headline)
                                                .padding(.horizontal)
                                        }
                                        .confirmationDialog("Remove Account?", isPresented: $showDelete, titleVisibility: .visible) {
                                            Button(role: .cancel) {
                                                print("canceled")
                                            } label: {
                                                Text("cancel")
                                            }
                                            
                                            Button(role: .destructive) {
                                                logOut()
                                            } label: {
                                                Text("Remove")
                                            }
                                        }
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
                        
                        DisclosureGroup(isExpanded: $isExpanded) {
                            VStack(spacing: 10) {
                                Link(destination: URL(string: "spotify.com")!) {
                                    HStack {
                                        Text("View our Terms of Use")
                                            .foregroundColor(Color("MainColor"))
                                            .font(.headline)
                                        
                                        Spacer()
                                    }
                                }
                                
                                Link(destination: URL(string: "spotify.com")!) {
                                    HStack {
                                        Text("View our Privacy Policy")
                                            .foregroundColor(Color("MainColor"))
                                            .font(.headline)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                        } label: {
                            Text("Privacy Policy & Terms")
                                .foregroundColor(Color("MainColor"))
                                .font(.headline)
                        }
                        .padding(8)
                        .padding(.horizontal)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            GADBannerViewController(adSize: GADAdSizeMediumRectangle)
                                .frame(width: GADAdSizeMediumRectangle.size.width, height: GADAdSizeMediumRectangle.size.height)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Accounts")
        }
        .accentColor(.primary)
        .onOpenURL { url in
            Task {
                await spotify.HandleURLCode(url)
            }
        }
        .task {
            if SpotifyAM.isSignedIn {
                currentUser = try? await spotifyData.getProfile()
            }
        }
    }
    
    func logOut() {
        Task {
            do {
                try await SpotifyAuthManager.deleteToken(service: "spotify.com", accounr: "accessToken")
                
                try await SpotifyAuthManager.deleteToken(service: "spotify.com", accounr: "refreshToken")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var loadingView: some View {
        VStack {
            Text("Loading")
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            ProgressView()
                .font(.largeTitle)
                .foregroundColor(.primary)
        }
    }
}
