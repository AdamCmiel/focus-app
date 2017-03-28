//
//  Notification.swift
//  focus
//
//  Created by Adam Cmiel on 3/27/17.
//  Copyright © 2017 Adam Cmiel. All rights reserved.
//

enum Notification : String {
    case hasBlankedScreen = "com.apple.springboard.hasBlankedScreen"
    case lockcomplete = "com.apple.springboard.lockcomplete"
    case lockstate = "com.apple.springboard.lockstate"
}


extension Notification {
    static let allCases = [
        Notification.hasBlankedScreen,
        Notification.lockcomplete,
        Notification.lockstate
    ].map { $0.rawValue }
    
    // In the order of events fired
    static let screenLocked: [Notification] = [.hasBlankedScreen, .lockstate, .lockcomplete]
    
    // In the order of events fired
    static let screenOpened: [Notification] = [.lockstate, .hasBlankedScreen]
}

extension Notification : CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .hasBlankedScreen: return "H"
        case .lockcomplete: return "C"
        case .lockstate: return "S"
        }
    }
}
