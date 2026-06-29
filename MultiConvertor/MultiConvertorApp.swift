//
//  MultiConvertorApp.swift
//  MultiConvertor
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftData
import SwiftUI

@main
struct MultiConvertorApp: App {

	let sharedModelContainer: ModelContainer
	let currencyService: CurrencyService
	let settingsService: SingletonModelService<AppSettings>
	let metadataService: SingletonModelService<AppMetadata>

	init() {
		let schema = Schema([
			Cryptocurrency.self,
			FiatCurrency.self,
			AppSettings.self,
			AppMetadata.self,
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

			self.sharedModelContainer = container

			// Initialize Repository and Services
			let context = container.mainContext
			let repoCrypto = CryptoRepository(modelContext: context)
			let repoFiat = FiatRepository(modelContext: context)
			let repoAll = AllRepository(
				modelContext: context, cryptoRepo: repoCrypto,
				fiatRepo: repoFiat)

			let cloudKitService = CloudKitService()

			let cryptoService = CryptocurrencyService(
				repository: repoAll, cloudKitService: cloudKitService)
			let fiatService = FiatCurrencyService(
				repository: repoAll, cloudkitService: cloudKitService)

			self.currencyService = CurrencyService(
				fiatService: fiatService, cryptoService: cryptoService,
				currencyRepository: repoAll)

			self.settingsService = SingletonModelService(
				modelContext: context, defaultInstance: AppSettings())
			self.metadataService = SingletonModelService(
				modelContext: context, defaultInstance: AppMetadata())

		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}

	var body: some Scene {
		WindowGroup {
			MainTabView()
				.environment(\.currencyService, currencyService)
				.environment(\.settingsService, settingsService)
				.environment(\.metadataService, metadataService)
		}
		.modelContainer(sharedModelContainer)
	}
}
