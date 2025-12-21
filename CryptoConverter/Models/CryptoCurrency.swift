//
//  CryptoCurrency.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftData
import SwiftUI
import CloudKit

@Model
class CryptoCurrency {
	var id: String = ""
	var name: String = ""
    var value: Double = 0.0
	var favourite: Bool = false
    var marketCap: Double = 0.0
	var sortOrder: Int?

	init(id: String, name: String, value: Double, marketCap: Double) {
		self.id = id
		self.name = name
		self.value = value
		self.marketCap = marketCap
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
    
    convenience init?(record: CKRecord) {
            // Map CloudKit keys to your properties
            // Use "as?" to safely cast types
            guard let id = record["id"] as? String,
                  let name = record["name"] as? String,
                  let value = record["value"] as? Double,
                  let marketCap = record["marketCap"] as? Double else {
                return nil
            }
            
            self.init(id: id, name: name, value: value, marketCap: marketCap)
            
            // Handle optional or defaulted values
            self.favourite = record["favourite"] as? Bool ?? false
            self.sortOrder = record["sortOrder"] as? Int
        }

}
