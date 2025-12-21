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
    @Attribute(.externalStorage) private var renderedLogoData: Data? // The cached PNG/UIImage data
    var marketCap: Double = 0.0
    var sortOrder: Int?
    
    init(id: String, name: String, value: Double, marketCap: Double, renderedLogoData: Data?) {
        self.id = id
        self.name = name
        self.value = value
        self.marketCap = marketCap
        self.renderedLogoData = renderedLogoData
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
        
        let data = logoString.data(using: .utf8)
        // Render SVG to a standard UIImage once to not spend time computing in the main thread with a computed property
        let renderedLogoData: Data? = if let uiImage = SVGKImage(data: data)?.uiImage {
            uiImage.pngData()
        } else {
            nil
        }
        
        self.init(id: id, name: name, value: value, marketCap: marketCap, renderedLogoData: renderedLogoData)
        
        // Handle optional or defaulted values
        self.favourite = record["favourite"] as? Bool ?? false
        self.sortOrder = record["sortOrder"] as? Int
    }
    
    // This property is now lightning fast because it just wraps existing Data
    var logo: UIImage? {
        guard let renderedLogoData else { return nil }
        return UIImage(data: renderedLogoData)
    }
}
