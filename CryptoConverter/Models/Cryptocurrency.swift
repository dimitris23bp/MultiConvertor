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
    @Attribute(.externalStorage) var iconData: Data?
    var sortOrder: Int?
    
    var icon: UIImage? {
        if let data = iconData, let uiImage = UIImage(data: data) {
            return uiImage
        }
        return nil
    }
        
    init(id: String, name: String, value: Double, marketCap: Double, iconData: Data?) {
        self.id = id
        self.name = name
        self.value = value
        self.marketCap = marketCap
        self.iconData = iconData
    }

    convenience init(dto: CryptocurrencyDTO) {
        self.init(id: dto.id, name: dto.name, value: dto.value, marketCap: dto.marketCap, iconData: dto.iconData)
    }
    
    convenience init?(record: CKRecord) {
        // Map CloudKit keys to your properties
        // Use "as?" to safely cast types
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let marketCap = record["marketCap"] as? Double,
              let logoData = record["logo"] as? Data
        else {
            return nil
        }
        
        self.init(id: id, name: name, value: value, marketCap: marketCap, iconData: logoData)
    }
}
