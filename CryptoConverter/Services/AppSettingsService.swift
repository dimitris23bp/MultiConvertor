import Combine
import Foundation
import SwiftData

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
