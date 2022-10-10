//
//  Extentions.swift
//  TBD
//
//  Created by Sean P. Meek on 4/17/22.
//

import Foundation
import SwiftUI

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}

//extension [String]: RawRepresentable {
//    public typealias RawValue = String
//
//    
//}
