//
//  CryptoConverterApp.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftUI
import SwiftData

@main
struct CryptoConverterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CryptoCurrency.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

//	init() {
//		seedIfNeeded(using: sharedModelContainer)
//	}

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

//private func seedIfNeeded(using container: ModelContainer) {
//	let context = ModelContext(container)
//
//	do {
//		var descriptor = FetchDescriptor<CryptoCurrency>()
//		descriptor.fetchLimit = 1
//
//		// Only seed if there are no CryptoCurrency records yet.
//		let isEmpty = try context.fetch(descriptor).isEmpty
//		guard isEmpty else { return }
//
//		// Example seed data — adjust to your model’s init/fields.
//		let seeds: [CryptoCurrency] = [
//			CryptoCurrency(symbol: "BTC", name: "Bitcoin", ),
//			CryptoCurrency(symbol: "ETH", name: "Ethereum"),
//		]
//
//		for item in seeds {
//			context.insert(item)
//		}
//
//		try context.save()
//	} catch {
//		// Consider logging non-fatal errors here
//		print("Seeding error: \(error)")
//	}
//}
