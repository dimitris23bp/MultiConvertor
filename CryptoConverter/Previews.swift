//
//  Previews.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftData
import Foundation
import SwiftUI

struct Previews {
	static var previewBtc: CryptoCurrency {
		CryptoCurrency(
			id: "BTC",
			name: "Bitcoin",
			value: 60000,
			marketCap: 6_000_000
		)
	}

	static var previewEth: CryptoCurrency {
		CryptoCurrency(
			id: "ETH",
			name: "Ether",
			value: 20000,
			marketCap: 3_300_000
		)
	}

	// The sample preview db
	static let preview: ModelContainer = {
		let container = try! ModelContainer(for: CryptoCurrency.self,
											 configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		container.mainContext.insert(previewBtc)
		container.mainContext.insert(previewEth)

		return container
	}()
}
