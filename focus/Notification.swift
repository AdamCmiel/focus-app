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
    
    static let allCases = [
        Notification.hasBlankedScreen,
        Notification.lockcomplete,
        Notification.lockstate
    ].map { $0.rawValue }
    
    // In the order of events fired
    static let screenLocked: [Notification] = [.hasBlankedScreen, .lockcomplete, .lockstate]
    
    // In the order of events fired
    static let screenOpened: [Notification] = [.lockstate, .hasBlankedScreen]
}
