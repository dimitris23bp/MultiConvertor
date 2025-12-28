import OSLog

/// A central point for all application logging categories.
enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.myorganization.CryptoConverter"

    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let service = Logger(subsystem: subsystem, category: "service")
    static let repository = Logger(subsystem: subsystem, category: "repository")
}
