enum Notification : String {
    
    // Fired when the screen is darkened
    case hasBlankedScreen = "com.apple.springboard.hasBlankedScreen"
    
    // Fired when the screen is locked
    case lockcomplete = "com.apple.springboard.lockcomplete"
    
    // Fired when the screen changes lock state
    case lockstate = "com.apple.springboard.lockstate"
    
}


extension Notification {
    
    static let allCases = [
        Notification.hasBlankedScreen,
        Notification.lockcomplete,
        Notification.lockstate
    ].map { $0.rawValue }
    
    /// In the order of events fired
    static let screenLocked: [Notification] = [.hasBlankedScreen, .lockstate, .lockcomplete]
    
    /// In the order of events fired
    static let screenOpened: [Notification] = [.lockstate, .hasBlankedScreen]
    
}

/// Write out only one letter for each event in debug
extension Notification : CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
        case .hasBlankedScreen: return "H"
        case .lockcomplete: return "C"
        case .lockstate: return "S"
        }
    }
    
}
