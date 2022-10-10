//
//  PlayBackManager.swift
//  TBD
//
//  Created by Sean P. Meek on 6/21/22.
//

import Foundation
import AVFoundation

class PlayBackManager: ObservableObject {
    static func formatTime(time: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        let string = formatter.string(from: time)
        return string ?? "0:00"
    }
}
