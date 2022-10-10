//
//  GoogleAdsView.swift
//  VybeCheck
//
//  Created by Sean P. Meek on 7/20/22.
//

import Foundation
import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

struct GADBannerViewController: UIViewControllerRepresentable {
    let adSize: GADAdSize
//  let adUnit: string
    func makeUIViewController(context: Context) -> some UIViewController {
        let view = GADBannerView(adSize: adSize)
        let viewController = UIViewController()
        let testID = "ca-app-pub-3940256099942544/2934735716"
//        let realID = "ca-app-pub-7042022413601168/9297968923"
        
        view.adUnitID = testID
        view.rootViewController = viewController
        
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: adSize.size)
        
        view.load(GADRequest())
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
