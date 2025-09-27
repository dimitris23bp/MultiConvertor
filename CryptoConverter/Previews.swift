//
//  Previews.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftData
import Foundation

struct Previews {
	static var previewCryptocurrency: CryptoCurrency {
		CryptoCurrency(
			id: "1",
			name: "Bitcoin",
			value: 60000,
			imageUrl: URL(string:"https://example.com/bitcoin.png")!
		)
	}

	// The sample preview db
	static let preview: ModelContainer = {
		let container = try! ModelContainer(for: CryptoCurrency.self,
											 configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		container.mainContext.insert(previewCryptocurrency)

		return container
	}()
}
