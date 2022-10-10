//
//  UserView.swift
//  TBD
//
//  Created by Sean P. Meek on 6/13/22.
//

import SwiftUI
import SDWebImageSwiftUI
import GoogleMobileAds

struct UserView: View {
    @State var topTrack: topTrackModel? = nil
    @State var topArtist: topArtistModel? = nil
    @State var adUnit: String = "ca-app-pub-7042022413601168/7614240211"
    @AppStorage("favArtists") static var favArtists: String = ""
    
    let spotifyGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)), Color(#colorLiteral(red: 0.1903857588, green: 0.8321116255, blue: 0.4365008013, alpha: 1))]
        ),
        startPoint: .leading, endPoint: .trailing
    )
    @StateObject var spotifyData = SpotifyDataManager()
    
    let gradient = LinearGradient(colors: [Color("MainColor"), Color(uiColor: .systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    let userName: String
    let uri: String
    let image: String?
    
    var body: some View {
        ZStack {
            gradient
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 0) {
                    if image != nil {
                        WebImage(url: URL(string: image!)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle")
                            .font(.system(size: 150))
                    }
                    
                    Text(userName)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(.bottom)
                        .padding(.vertical, 8)
                    
                    if UIApplication.shared.canOpenURL(URL(string: "spotify://")!) {
                        Link(destination: URL(string: uri) ?? URL(string: "spotify:")!) {
                            Text("View on Spotify")
                                .padding(8)
                                .foregroundColor(.primary)
                                .frame(width: UIScreen.main.bounds.width * 0.95)
                                .background(spotifyGradient)
                                .cornerRadius(15)
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                    } else {
                        Link(destination: URL(string: "https://itunes.apple.com/app/spotify-music/id324684580")!) {
                            Text("Get Spotify Free")
                                .padding(8)
                                .foregroundColor(.primary)
                                .frame(width: UIScreen.main.bounds.width * 0.95)
                                .background(spotifyGradient)
                                .cornerRadius(15)
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Spacer()
                        
                        if UIApplication.shared.canOpenURL(URL(string: "spotify://")!) {
                            if let trackURI = topTrack?.items.first?.uri {
                                Link(destination: URL(string: trackURI) ?? URL(string: "spotify:")!) {
                                    favTrack
                                }
                            }
                        } else {
                            Link(destination: URL(string: "https://itunes.apple.com/app/spotify-music/id324684580")!) {
                                favTrack
                            }
                        }
                        
                        Spacer()
                        
                        if UIApplication.shared.canOpenURL(URL(string: "spotify://")!) {
                            if let ArtistURI = topArtist?.items.first?.uri {
                                Link(destination: URL(string: ArtistURI) ?? URL(string: "spotify:")!) {
                                    favArtist
                                }
                            }
                        } else {
                            Link(destination: URL(string: "https://itunes.apple.com/app/spotify-music/id324684580")!) {
                                favArtist
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        GADBannerViewController(adSize: GADAdSizeLargeBanner)
                            .frame(width: GADAdSizeLargeBanner.size.width, height: GADAdSizeLargeBanner.size.height)
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                async let image1 = spotifyData.getTopTrack()
                async let image2 = spotifyData.getTopArtist()
                
                (topTrack, topArtist) = await (try image1, try image2)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var favTrack: some View {
        VStack {
            Text("Favorite Track")
                .foregroundColor(.primary)
                .font(.title3)
            
            if spotifyData.isRetrievingData {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width * 0.45, height: UIScreen.main.bounds.width * 0.45)
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                
                Text("Favorite Track")
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                    .font(.headline)
                    .lineLimit(2)
            } else {
                if let imageURL = topTrack?.items.first?.album.images.first?.url {
                    WebImage(url: URL(string: imageURL) ?? URL(string: "")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.45, height: UIScreen.main.bounds.width * 0.45)
                }
                
                Text(topTrack?.items.first?.name ?? "")
                    .foregroundColor(.secondary)
                    .font(.headline)
                    .lineLimit(2)
            }
        }
    }
    
    var favArtist: some View {
        VStack {
            Text("Favorite Artist")
                .foregroundColor(.primary)
                .font(.title3)
            
            if spotifyData.isRetrievingData {
                Circle()
                    .frame(width: UIScreen.main.bounds.width * 0.45, height: UIScreen.main.bounds.width * 0.45)
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                
                Text("Favorite Artist")
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                    .font(.headline)
                    .lineLimit(2)
            } else {
                if let artistImage = topArtist?.items.first?.images?.first?.url {
                    WebImage(url: URL(string: artistImage) ?? URL(string: "")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.45, height: UIScreen.main.bounds.width * 0.45)
                        .clipShape(Circle())
                }
                
                Text(topArtist?.items.first?.name ?? "")
                    .foregroundColor(.secondary)
                    .font(.headline)
                    .lineLimit(2)
            }
        }
    }
}
