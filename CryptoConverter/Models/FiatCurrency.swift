import SwiftData
import SwiftUI
import CloudKit

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
        guard let iconData = iconData else { return nil }
        return UIImage(data: iconData)
    }
        
    init(id: String, name: String, value: Double, popularity: Int, iconData: Data?) {
        self.id = id
        self.name = name
        self.value = value
        self.popularity = popularity
        self.iconData = iconData
    }

    convenience init(dto: FiatCurrencyDTO) {
        self.init(id: dto.id, name: dto.name, value: dto.value, popularity: dto.popularity, iconData: dto.iconData)
    }
}
