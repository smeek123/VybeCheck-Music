//
//  RecommendedTrack.swift
//  TBD
//
//  Created by Sean P. Meek on 6/20/22.
//

import SwiftUI
import SDWebImageSwiftUI
import AVKit
import GoogleMobileAds

struct RecommendedTrackView: View {
    @StateObject var spotifyData = SpotifyDataManager()
    @State var timeValue: TimeInterval = 0
    @State var timePast: String = "00:00"
    @State var timeLeft: String = "00:30"
    @StateObject var spotifyPlay = PlayBackManager()
    @State var player = AVPlayer()
    @State var isPlaying: Bool = false
    @State var seekTime: CMTime = CMTimeMake(value: 10, timescale: 1)
    @State var observer: Any = []
    @State var showError: Bool = false
    let vybe: String
    @Environment(\.presentationMode) var isPresented
    @State var adUnit: String = "ca-app-pub-7042022413601168/9297968923"
    @State var shareLink: URL = URL(string: "")!
    @State var shareMessage: String = ""
    
    let gradient = LinearGradient(colors: [Color("MainColor"), Color(uiColor: .systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    let spotifyGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)), Color(#colorLiteral(red: 0.1903857588, green: 0.8321116255, blue: 0.4365008013, alpha: 1))]
        ),
        startPoint: .leading, endPoint: .trailing
    )
    
    let track: track?
    
    private func makeShareItem() {
        if let song = track?.name, let artist = track?.artists?.first?.name, let url = track?.external_urls?.spotify {
            if vybe != "energetic" && vybe != "angry" {
                shareMessage = "VybeCheck says I might like \"\(song)\" by \"\(artist)\" for a \(vybe) vibe 🔥. Check it out on Spotify here: "
                shareLink = URL(string: url) ?? URL(string: "https://open.spotify.com")!
            } else if vybe == "angry" || vybe == "energetic" {
                shareMessage = "VybeCheck says I might like \"\(song)\" by \"\(artist)\" for an \(vybe) vibe 🔥. Check it out on Spotify here: "
                shareLink = URL(string: url) ?? URL(string: "https://open.spotify.com")!
            }
        }
    }
    
    var body: some View {
        ZStack {
            gradient
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                if spotifyData.isRetrievingData {
                    VStack {
                        Spacer()
                        
                        Text("Loading")
                            .foregroundColor(.primary)
                            .font(.largeTitle)
                        
                        ProgressView()
                            .foregroundColor(.primary)
                            .font(.largeTitle)
                        
                        Spacer()
                    }
                } else {
                    if track != nil {
                        VStack(alignment: .center, spacing: 0) {
                            HStack {
                                Button {
                                    self.isPresented.wrappedValue.dismiss()
                                    
                                    HapticViewModel.instance.impact(style: .light)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.title)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                Text(vybe.uppercased())
                                    .foregroundColor(.primary)
                                    .font(.title)
                                
                                Spacer()
                                
                                ShareLink(item: shareLink, subject: Text("VybeCheck"), message: Text(shareMessage)) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            if let image = track?.album.images.first?.url {
                                WebImage(url: URL(string: image) ?? URL(string: "")!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.width * 0.75)
                                    .padding(.vertical)
                            }
                            
                            VStack(spacing: 0) {
                                Text(track?.name ?? "name")
                                    .foregroundColor(.primary)
                                    .font(.title)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                
                                Text(track?.artists?.first?.name ?? "artist")
                                    .foregroundColor(.secondary)
                                    .font(.title)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 5)
                                
                                if ((track?.explicit) != nil && (track?.explicit) == true) {
                                    Text("(explicit)")
                                        .foregroundColor(.secondary)
                                        .font(.title3)
                                        .padding(.bottom)
                                }
                            }
                            
                            if track?.restrictions != nil {
                                Text(track?.restrictions?.reason ?? "")
                                    .foregroundColor(.primary)
                                    .font(.headline)
                            } else {
                                if track?.preview_url != nil {
                                    VStack(spacing: 2) {
                                        Slider(value: $timeValue, in: 0...30, onEditingChanged: { _ in
                                            player.seek(to: CMTimeMake(value: Int64(timeValue), timescale: 1))
                                        })
                                        .accentColor(.primary)
                                        
                                        HStack {
                                            Text(String(timePast))
                                                .foregroundColor(.primary)
                                                .font(.title3)
                                            
                                            Spacer()
                                            
                                            Text(String("-" + timeLeft))
                                                .foregroundColor(.primary)
                                                .font(.title3)
                                        }
                                    }
                                    .onAppear {
                                        if let url = URL(string: track?.preview_url ?? "") {
                                            player = AVPlayer(playerItem: AVPlayerItem(url: url))
                                            observer = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 2), queue: nil) { current in
                                                timePast = PlayBackManager.formatTime(time: CMTimeGetSeconds(current))
                                                timeLeft = PlayBackManager.formatTime(time: CMTimeGetSeconds(player.currentItem!.duration))
                                                timeValue = CMTimeGetSeconds(current)
                                                if timePast == "00:29" {
                                                    isPlaying = false
                                                    player.seek(to: CMTimeMake(value: 0, timescale: 1))
                                                    player.pause()
                                                }
                                            }
                                        }
                                    }
                                    .onDisappear {
                                        player.pause()
                                        isPlaying = false
                                        player.removeTimeObserver(observer)
                                        player = AVPlayer()
                                    }
                                    
                                    HStack(alignment: .center) {
                                        Spacer()
                                        
                                        Button {
                                            if CMTimeGetSeconds(player.currentTime()-seekTime) >= 0 {
                                                player.seek(to: player.currentTime()-seekTime)
                                            }
                                            
                                            HapticViewModel.instance.impact(style: .medium)
                                        } label: {
                                            Image(systemName: "gobackward.10")
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 30))
                                                .padding(.vertical)
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            if isPlaying {
                                                isPlaying = false
                                                player.pause()
                                            } else {
                                                isPlaying = true
                                                player.play()
                                            }
                                        } label: {
                                            if isPlaying {
                                                Image(systemName: "pause.circle.fill")
                                                    .foregroundColor(.primary)
                                                    .font(.system(size: 60))
                                                    .padding(.vertical)
                                            } else {
                                                Image(systemName: "play.circle.fill")
                                                    .foregroundColor(.primary)
                                                    .font(.system(size: 60))
                                                    .padding(.vertical)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            if CMTimeGetSeconds(player.currentTime()+seekTime) < CMTimeGetSeconds(player.currentItem!.duration) {
                                                player.seek(to: player.currentTime()+seekTime)
                                            }
                                            
                                            HapticViewModel.instance.impact(style: .medium)
                                        } label: {
                                            Image(systemName: "goforward.10")
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 30))
                                                .padding(.vertical)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.bottom)
                                } else {
                                    Text("No preview for this track")
                                        .foregroundColor(.primary)
                                        .font(.title3)
                                        .padding()
                                    
                                    HStack {
                                        Spacer()
                                        GADBannerViewController(adSize: GADAdSizeLargeBanner)
                                            .frame(width: GADAdSizeLargeBanner.size.width, height: GADAdSizeLargeBanner.size.height)
                                        Spacer()
                                    }
                                    .padding()
                                }
                            }
                            
                            if let uri = track?.uri {
                                if UIApplication.shared.canOpenURL(URL(string: "spotify://")!) {
                                    Link(destination: URL(string: uri) ?? URL(string: "spotify:")!) {
                                        HStack(spacing: 20) {
                                            Image("WhiteSpotifyIcon")
                                                .interpolation(.high)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 50)
                                            Text("Listen on Spotify")
                                                .font(.system(size: 30))
                                                .foregroundColor(.white)
                                        }
                                        .background(RoundedRectangle(cornerRadius: 15)
                                            .fill(spotifyGradient)
                                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.1))
                                        .padding(.vertical)
                                    }
                                    .padding(.vertical)
                                } else {
                                    Link(destination: URL(string: "https://itunes.apple.com/app/spotify-music/id324684580")!) {
                                        HStack(spacing: 20) {
                                            Image("WhiteSpotifyIcon")
                                                .interpolation(.high)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 50)
                                            Text("Get Spotify Free")
                                                .font(.system(size: 30))
                                                .foregroundColor(.white)
                                        }
                                        .background(RoundedRectangle(cornerRadius: 15)
                                            .fill(spotifyGradient)
                                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.1))
                                        .padding(.vertical)
                                    }
                                    .padding(.vertical)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                    } else {
                        VStack {
                            HStack {
                                Button {
                                    self.isPresented.wrappedValue.dismiss()
                                    
                                    HapticViewModel.instance.impact(style: .light)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.title)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                Text(vybe.uppercased())
                                    .foregroundColor(.primary)
                                    .font(.title)
                                
                                Spacer()
                                
                            }
                            .padding()
                            
                            Text("Spotify does not have any recommendations for this vybe and your music taste. By listening to more tracks, Spotify can suggest more for this bybe.")
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Spacer()
                            
                            if UIApplication.shared.canOpenURL(URL(string: "spotify://")!) {
                                Link(destination: URL(string: "spotify:")!) {
                                    HStack(spacing: 20) {
                                        Image("WhiteSpotifyIcon")
                                            .interpolation(.high)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 50)
                                        Text("Listen on Spotify")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }
                                    .background(RoundedRectangle(cornerRadius: 15)
                                        .fill(spotifyGradient)
                                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.1))
                                    .padding(.vertical)
                                }
                                .padding(.vertical)
                            } else {
                                Link(destination: URL(string: "https://itunes.apple.com/app/spotify-music/id324684580")!) {
                                    HStack(spacing: 20) {
                                        Image("WhiteSpotifyIcon")
                                            .interpolation(.high)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 50)
                                        Text("Get Spotify Free")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    }
                                    .background(RoundedRectangle(cornerRadius: 15)
                                        .fill(spotifyGradient)
                                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.1))
                                    .padding(.vertical)
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            makeShareItem()
        }
    }
}
