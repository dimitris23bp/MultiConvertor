import OSLog

/// A central point for all application logging categories.
enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.myorganization.CryptoConverter"

    nonisolated static let ui = Logger(subsystem: subsystem, category: "UI")
    nonisolated static let service = Logger(subsystem: subsystem, category: "service")
    nonisolated static let repository = Logger(subsystem: subsystem, category: "repository")
	nonisolated static let mapper = Logger(subsystem: subsystem, category: "mapper")
}
