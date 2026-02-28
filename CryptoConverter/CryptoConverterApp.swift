//
//  CryptoConverterApp.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftData
import SwiftUI

@main
struct CryptoConverterApp: App {

	var sharedModelContainer: ModelContainer = {

		let schema = Schema([
			Cryptocurrency.self,
			FiatCurrency.self,
			AppSettings.self,
		])

		let isPreview =
			ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
			== "1"
		let modelConfiguration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: isPreview,
			cloudKitDatabase: .none
		)

		do {
			let container = try ModelContainer(
				for: schema,
				configurations: modelConfiguration
			)

			if isPreview {
				let context = container.mainContext
				context.insert(Previews.previewBtc)
				context.insert(Previews.previewEth)
				context.insert(Previews.previewDot)
				context.insert(Previews.previewEur)
				context.insert(Previews.previewUsd)
			}

			return container
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()

	var body: some Scene {
		WindowGroup {
			MainTabView()
		}
		.modelContainer(sharedModelContainer)
	}
}
