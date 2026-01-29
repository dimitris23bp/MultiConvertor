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
        guard let iconData = iconData else { return nil }
        return UIImage(data: iconData)
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
}
