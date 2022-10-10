//
//  RemoteConfigViewModel.swift
//  VybeCheck
//
//  Created by Sean P. Meek on 7/7/22.
//

import Foundation
import FirebaseRemoteConfig

class RemoteConfigManager: ObservableObject {
    static let instance = RemoteConfigManager()
    
    @Published var connectDescription: String = "Connecting a streaming service account will allow music recommendations to be made. This also provides the ability to play songs directly in your preferred streaming service."
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    func fetchValues() {
        let defaults: [String: NSObject] = ["connect_description": "Connecting a streaming service account will allow music recommendations to be made. This also provides the ability to play songs directly in your preferred streaming service." as NSObject]
        
        remoteConfig.setDefaults(defaults)
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }
}
