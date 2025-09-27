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
//	var imageUrl: URL

	init(id: String, name: String, value: Double, imageData: Data) {
		self.id = id
		self.name = name
		self.value = value
		self.imageData = imageData
	}

	init(id: String, name: String, value: Double) {
		self.id = id
		self.name = name
		self.value = value
	}

	var image: Image? {
		if let data = imageData, let uiImage = UIImage(data: data) {
			return Image(uiImage: uiImage)
		}
		return Image(systemName: "questionmark")
	}

	convenience init?(ticker: CryptoTicker) {
		guard let price = Double(ticker.priceUsd) else {
			// TODO: In this case, don't even save this item
			return nil
		}
		self.init(id: ticker.symbol,
				  name: ticker.name,
				  value: price
		)
	}

	// TODO: Probably no need for a setter in swift. I don't really know yet
//	func updateImageData(_ data: Data) {
//		self.imageData = data
//	}

}
