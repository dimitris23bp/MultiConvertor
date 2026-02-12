import SwiftData
import Foundation

@Model
final class AppSettings {
    private var displayModeRaw: String  // Store as String for SwiftData compatibility
	var cryptoDecimals: Int
	var fiatDecimals: Int
    
    var displayMode: DisplayMode {
        get { DisplayMode(rawValue: displayModeRaw) ?? .merged }
        set { displayModeRaw = newValue.rawValue }
    }

	init(displayMode: DisplayMode = .merged, cryptoDecimals: Int = 7, fiatDecimals: Int = 7) {
        self.displayModeRaw = displayMode.rawValue
		self.cryptoDecimals = cryptoDecimals
		self.fiatDecimals = fiatDecimals
    }
}
