import Combine
import Foundation
import SwiftData
import SwiftUI

class AppMetadataService: ObservableObject {

	@Published var metadata: AppMetadata
	private let modelContext: ModelContext

	init(modelContext: ModelContext) {
		self.modelContext = modelContext

		// Load existing metadata or create defaults
		let fetchDescriptor = FetchDescriptor<AppMetadata>()
		if let existing = try? modelContext.fetch(fetchDescriptor).first {
			self.metadata = existing
		} else {
			let newMetadata = AppMetadata()
			modelContext.insert(newMetadata)
			self.metadata = newMetadata
			try? modelContext.save()
		}
	}

	func save() {
		try? modelContext.save()
	}
}

// MARK: - Environment Setup

struct MetadataServiceKey: EnvironmentKey {
	// If it is not provided on the top level, return nil
	static let defaultValue: AppMetadataService? = nil
}

extension EnvironmentValues {
	var metadataService: AppMetadataService? {
		get { self[MetadataServiceKey.self] }
		set { self[MetadataServiceKey.self] = newValue }
	}
}
