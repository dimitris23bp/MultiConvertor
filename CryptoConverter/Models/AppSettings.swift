import SwiftData
import Foundation

@Model
final class AppSettings {
    var displayMode: DisplayMode
    // Future settings can be added here

    init(displayMode: DisplayMode = .merged) {
        self.displayMode = displayMode
    }
}