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
class Cryptocurrency {
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
    @Attribute(.externalStorage) var renderedLogoData: Data?
    var sortOrder: Int?
    
    // LogoString is not included and renderedLogoData can be added later
    init(id: String, name: String, value: Double, marketCap: Double) {
        self.id = id
        self.name = name
        self.value = value
        self.marketCap = marketCap
    }
        
    init(id: String, name: String, value: Double, marketCap: Double, logoString: String) {
        self.id = id
        self.name = name
        self.value = value
        self.marketCap = marketCap
        
        // This is a convention for the previews
        if logoString == "preview" {
            self.renderedLogoData = logoString.data(using: .utf8)
        } else {
            // Render SVG to a standard UIImage once to not spend time computing in the main thread with a computed property
            let data = logoString.data(using: .utf8)
            let svgkImage = SVGKImage(data: data)
            let renderedLogoData: Data? = if let uiImage = svgkImage?.uiImage {
                uiImage.pngData()
            } else {
                nil
            }
            self.renderedLogoData = renderedLogoData
        }
        
    }

    convenience init(dto: CryptocurrencyDTO) {
        self.init(id: dto.id, name: dto.name, value: dto.value, marketCap: dto.marketCap)
        // Overwrite the logo data with the pre-calculated one from the DTO
        self.renderedLogoData = dto.renderedLogoData
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
    
    // This property is fast enough, because it just wraps existing Data
    var logo: UIImage? {
        // This is a convention for the previews
        if renderedLogoData == "preview".data(using: .utf8) {
            return UIImage(systemName: "questionmark.circle")
        }
        guard let renderedLogoData else { return nil }
        return UIImage(data: renderedLogoData)
    }
}
