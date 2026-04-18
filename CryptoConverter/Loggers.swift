import OSLog

/// A central point for all application logging categories.
enum Log {
	private static let subsystem =
		Bundle.main.bundleIdentifier ?? "com.myorganization.CryptoConverter"

	nonisolated static let ui = Logger(subsystem: subsystem, category: "UI")
	nonisolated static let service = Logger(
		subsystem: subsystem,
		category: "service"
	)
	nonisolated static let repository = Logger(
		subsystem: subsystem,
		category: "repository"
	)
	nonisolated static let mapper = Logger(
		subsystem: subsystem,
		category: "mapper"
	)
}

extension Logger {
	/// Logs a debug message that is public in Debug builds but private in Release.
	nonisolated func debugApp(_ message: String) {
		#if DEBUG
		self.debug("\(message, privacy: .public)")
		#else
		self.debug("\(message, privacy: .private)")
		#endif
	}

	/// Logs an info message that is public in Debug builds but private in Release.
	nonisolated func infoApp(_ message: String) {
		#if DEBUG
		self.info("\(message, privacy: .public)")
		#else
		self.info("\(message, privacy: .private)")
		#endif
	}

	/// Logs a warning message that is public in Debug builds but private in Release.
	nonisolated func warningApp(_ message: String) {
		#if DEBUG
		self.warning("\(message, privacy: .public)")
		#else
		self.warning("\(message, privacy: .private)")
		#endif
	}

	/// Logs an error message that is public in Debug builds but private in Release.
	nonisolated func errorApp(_ message: String) {
		#if DEBUG
		self.error("\(message, privacy: .public)")
		#else
		self.error("\(message, privacy: .private)")
		#endif
	}
}
