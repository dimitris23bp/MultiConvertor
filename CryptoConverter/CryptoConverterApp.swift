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
            Cryptocurrency.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

