import SwiftData
import SwiftUI
import CloudKit
import SVGKit
import SVGView

@Model
class FiatCurrency : Currency {
    var id: String = ""
    var name: String = ""
    var value: Double = 0.0
    var favourite: Bool = false
    // Data to compute the flag
    // On external storage to not spend time computing it
    @Attribute(.externalStorage) var iconData: Data?
    var popularity: Int = 0
    var sortOrder: Int?
    
    var icon: UIImage? {
        if let data = iconData, let uiImage = UIImage(data: data) {
            return uiImage
        }
        return nil
    }
    
    // LogoString is not included and renderedLogoData can be added later
    init(id: String, name: String, value: Double, popularity: Int) {
        self.id = id
        self.name = name
        self.value = value
        self.popularity = popularity
    }
        
    init(id: String, name: String, value: Double, iconData: Data?, popularity: Int) {
        self.id = id
        self.name = name
        self.value = value
        self.popularity = popularity
        self.iconData = iconData
    }

    convenience init(dto: FiatCurrencyDTO) {
        self.init(id: dto.id, name: dto.name, value: dto.value, popularity: dto.popularity)
        // Overwrite the flag data with the pre-calculated one from the DTO
        self.iconData = dto.iconData
    }
    
    convenience init?(record: CKRecord) {
        // Map CloudKit keys to your properties
        // Use "as?" to safely cast types
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let popularity = record["order"] as? Int,
              let flagData = record["flag"] as? Data
        else {
            return nil
        }
        
        
        self.init(id: id, name: name, value: value, iconData: flagData, popularity: popularity)
    }
}
