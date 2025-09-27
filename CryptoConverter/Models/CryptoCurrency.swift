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
	var imageUrl: URL

	init(id: String, name: String, value: Double, imageUrl: URL) {
		self.id = id
		self.name = name
		self.value = value
		self.imageUrl = imageUrl
	}

//	var image: Image {
//		
//	}


}
