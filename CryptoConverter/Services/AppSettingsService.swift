import Combine
import Foundation
import SwiftData
import SwiftUI

class AppSettingsService: ObservableObject {

	@Published var settings: AppSettings
	private let modelContext: ModelContext

	init(modelContext: ModelContext) {
		self.modelContext = modelContext

		// Load existing settings or create defaults
		let fetchDescriptor = FetchDescriptor<AppSettings>()
		if let existing = try? modelContext.fetch(fetchDescriptor).first {
			self.settings = existing
		} else {
			let newSettings = AppSettings()
			modelContext.insert(newSettings)
			self.settings = newSettings
			try? modelContext.save()
		}
	}

	func save() {
		try? modelContext.save()
	}
}

	// MARK: - Environment Setup

	struct SettingsServiceKey: EnvironmentKey {
		// If it is not provided on the top level, return nil
		static let defaultValue: AppSettingsService? = nil
	}

	extension EnvironmentValues {
		var settingsService: AppSettingsService? {
			get { self[SettingsServiceKey.self] }
			set { self[SettingsServiceKey.self] = newValue }
		}
	}

