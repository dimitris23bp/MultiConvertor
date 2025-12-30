import SwiftData
import SwiftUI
import CloudKit
import SVGKit

@Model
class FiatCurrency : Currency {
    var id: String = ""
    var name: String = ""
    var value: Double = 0.0
    var favourite: Bool = false
    // Data to compute the flag
    // On external storage to not spend time computing it
    @Attribute(.externalStorage) var renderedFlagData: Data?
    var popularity: Int = 0
    var sortOrder: Int?
    
    var flag: UIImage? {
        // This is a convention for the previews
        if renderedFlagData == "preview".data(using: .utf8) {
            return UIImage(systemName: "questionmark.circle")
        }
        guard let renderedFlagData else { return nil }
        return UIImage(data: renderedFlagData)
    }

    var icon: UIImage? { flag }
    
    // LogoString is not included and renderedLogoData can be added later
    init(id: String, name: String, value: Double, popularity: Int) {
        self.id = id
        self.name = name
        self.value = value
        self.popularity = popularity
    }
        
    init(id: String, name: String, value: Double, flagString: String, popularity: Int) {
        self.id = id
        self.name = name
        self.value = value
        self.popularity = popularity
        
        // This is a convention for the previews
        if flagString == "preview" {
            self.renderedFlagData = flagString.data(using: .utf8)
        } else {
            // Render SVG to a standard UIImage once to not spend time computing in the main thread with a computed property
            let data = flagString.data(using: .utf8)
            let svgkImage = SVGKImage(data: data)
            let renderedFlagData: Data? = if let uiImage = svgkImage?.uiImage {
                uiImage.pngData()
            } else {
                nil
            }
            self.renderedFlagData = renderedFlagData
        }
        
    }

    convenience init(dto: FiatCurrencyDTO) {
        self.init(id: dto.id, name: dto.name, value: dto.value, popularity: dto.popularity)
        // Overwrite the flag data with the pre-calculated one from the DTO
        self.renderedFlagData = dto.renderedFlagData
    }
    
    convenience init?(record: CKRecord) {
        // Map CloudKit keys to your properties
        // Use "as?" to safely cast types
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let popularity = record["order"] as? Int,
              let flagString = record["flag"] as? String
        else {
            return nil
        }
        
        
        self.init(id: id, name: name, value: value, flagString: flagString, popularity: popularity)
    }
}
