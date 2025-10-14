//
//  CryptoCurrency.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftData
import SwiftUI

@Model
class CryptoCurrency {
	@Attribute(.unique) var id: String
	var name: String
	var value: Double
	var imageData: Data?
	var favourite: Bool = false
	var marketCap: Double
	var sortOrder: Int?


	init(id: String, name: String, value: Double, imageData: Data, marketCap: Double) {
		self.id = id
		self.name = name
		self.value = value
		self.imageData = imageData
		self.marketCap = marketCap
	}

	init(id: String, name: String, value: Double, marketCap: Double) {
		self.id = id
		self.name = name
		self.value = value
		self.marketCap = marketCap
	}

	var image: Image? {
		if let data = imageData, let uiImage = UIImage(data: data) {
			return Image(uiImage: uiImage)
		}
		return Image(systemName: "questionmark")
	}

	convenience init?(ticker: CryptoTicker) {
		guard let price = Double(ticker.priceUsd), let marketCap = Double(ticker.marketCapUsd) else {
			// TODO: In this case, don't even save this item
			return nil
		}
		self.init(id: ticker.symbol,
				  name: ticker.name,
				  value: price,
				  marketCap: marketCap
		)
	}

}
