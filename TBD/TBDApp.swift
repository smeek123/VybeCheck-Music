//
//  TBDApp.swift
//  TBD
//
//  Created by Sean P. Meek on 4/15/22.
//

import SwiftUI
import AVKit
import Firebase
import GoogleMobileAds
import AppTrackingTransparency

@main
struct TBDApp: App {
    func setAudioSession()  {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("error with audio session")
        }
    }
    
    init() {
        setAudioSession()
        
        FirebaseApp.configure()
        
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            //User has not indicated their choice for app tracking
            //You may want to show a pop-up explaining why you are collecting their data
            //Toggle any variables to do this here
        } else {
            ATTrackingManager.requestTrackingAuthorization { status in
                //Whether or not user has opted in initialize GADMobileAds here it will handle the rest
                
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
