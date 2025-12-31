//
//  CryptoCurrency.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftData
import SwiftUI
import CloudKit
import SVGView

@Model
class Cryptocurrency: Currency {
    // e.g. BTC
    var id: String = ""
    // e.g. Bitcoin
    var name: String = ""
    // e.g. 100.000 dollars
    var value: Double = 0.0
    // e.g. 1.000.000.000.000 dollars
    var marketCap: Double = 0.0
    var favourite: Bool = false
    // Data to compute the logo
    // On external storage to not spend time computing it
    @Attribute(.externalStorage) var iconString: String?
    var sortOrder: Int?
    
    var icon: (any View)? {
        // TODO: Have a preview SVG (maybe with a questionmark)
        SVGView(string: iconString ?? "")
    }

    // LogoString is not included and renderedLogoData can be added later
    init(id: String, name: String, value: Double, marketCap: Double) {
        self.id = id
        self.name = name
        self.value = value
        self.marketCap = marketCap
    }
        
    init(id: String, name: String, value: Double, marketCap: Double, iconString: String) {
        self.id = id
        self.name = name
        self.value = value
        self.marketCap = marketCap
        self.iconString = iconString
    }

    convenience init(dto: CryptocurrencyDTO) {
        self.init(id: dto.id, name: dto.name, value: dto.value, marketCap: dto.marketCap)
        // Overwrite the logo data with the pre-calculated one from the DTO
        // TODO: Do I need that anymore? Maybe this constructor is useless
        self.iconString = dto.iconString
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
        
        self.init(id: id, name: name, value: value, marketCap: marketCap, iconString: logoString)
    }
}
