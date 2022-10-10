//
//  HapticViewModel.swift
//  VybeCheck
//
//  Created by Sean P. Meek on 7/4/22.
//

import Foundation
import UIKit

class HapticViewModel: ObservableObject {
    static let instance = HapticViewModel()
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
