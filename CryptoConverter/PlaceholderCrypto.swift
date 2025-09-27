//
//  PlaceholderCrypto.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//
import Foundation
import UIKit

func placeholder() -> CryptoCurrency {

	guard let imageData = UIImage(named: "bitcoin")?.pngData() else {
		fatalError("Failed to load placeholder image data for bitcoin")
	}
	return CryptoCurrency(id: "PLC", name: "Placeholder", value: 50200, imageData: imageData)
}

func placeholder2() -> CryptoCurrency {
	guard let imageData = UIImage(named: "litecoin")?.pngData() else {
		fatalError("Failed to load placeholder image data for litecoin")
	}
	return CryptoCurrency(id: "ETH", name: "Ether", value: 20123, imageData: imageData)
}

