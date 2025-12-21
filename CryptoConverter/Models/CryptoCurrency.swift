//
//  CryptoCurrency.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftData
import SwiftUI
import CloudKit
import SVGKit

@Model
class CryptoCurrency {
	var id: String = ""
	var name: String = ""
    var value: Double = 0.0
	var favourite: Bool = false
     var logoString: String? = ""
    var marketCap: Double = 0.0
	var sortOrder: Int?

    init(id: String, name: String, value: Double, marketCap: Double, logoString: String?) {
		self.id = id
		self.name = name
		self.value = value
		self.marketCap = marketCap
        self.logoString = logoString
	}
    
    convenience init?(record: CKRecord) {
        // Map CloudKit keys to your properties
        // Use "as?" to safely cast types
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let marketCap = record["marketCap"] as? Double,
              let logoString = record["logo"] as? String
        else {
            return nil
        }
        self.init(id: id, name: name, value: value, marketCap: marketCap, logoString: logoString)
        
        // Handle optional or defaulted values
        self.favourite = record["favourite"] as? Bool ?? false
        self.sortOrder = record["sortOrder"] as? Int
        }
    
    var logo: UIImage? {
        guard let logoString = logoString,
              let data = logoString.data(using: .utf8) else { return nil }
        
        // SVGKImage is the "engine" that parses the XML string
        return SVGKImage(data: data)?.uiImage
    }
}
