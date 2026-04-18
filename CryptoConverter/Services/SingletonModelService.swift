import Combine
import Foundation
import SwiftData
import SwiftUI

/// A generic service to manage singleton-like SwiftData models (e.g., AppSettings, AppMetadata).
class SingletonModelService<T: PersistentModel>: ObservableObject {

	@Published var model: T
	private let modelContext: ModelContext

	// @autoclosure () -> T could be just T
	// If that was the case, I would create a defaultInstance even if I wouldn't need it
	// Now the defaultInstance is only created if it is requested in the `else` statement
	init(modelContext: ModelContext, defaultInstance: @autoclosure () -> T) {
		self.modelContext = modelContext

		// Load existing model or create default
		let fetchDescriptor = FetchDescriptor<T>()
		if let existing = try? modelContext.fetch(fetchDescriptor).first {
			self.model = existing
		} else {
			let newInstance = defaultInstance()
			modelContext.insert(newInstance)
			self.model = newInstance
			try? modelContext.save()
		}
	}

	func save() {
		try? modelContext.save()
	}

	deinit {}
}

// MARK: - Environment Setup

struct SettingsServiceKey: EnvironmentKey {
	static let defaultValue: SingletonModelService<AppSettings>? = nil
}

struct MetadataServiceKey: EnvironmentKey {
	static let defaultValue: SingletonModelService<AppMetadata>? = nil
}

extension EnvironmentValues {
	var settingsService: SingletonModelService<AppSettings>? {
		get { self[SettingsServiceKey.self] }
		set { self[SettingsServiceKey.self] = newValue }
	}

	var metadataService: SingletonModelService<AppMetadata>? {
		get { self[MetadataServiceKey.self] }
		set { self[MetadataServiceKey.self] = newValue }
	}
}
