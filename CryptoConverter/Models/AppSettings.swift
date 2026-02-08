import SwiftData
import Foundation

@Model
final class AppSettings {
    private var displayModeRaw: String  // Store as String for SwiftData compatibility
    // Future settings can be added here
    
    var displayMode: DisplayMode {
        get { DisplayMode(rawValue: displayModeRaw) ?? .merged }
        set { displayModeRaw = newValue.rawValue }
    }

    init(displayMode: DisplayMode = .merged) {
        self.displayModeRaw = displayMode.rawValue
    }
}
