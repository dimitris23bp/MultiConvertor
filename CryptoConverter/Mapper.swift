import CloudKit
import SVGKit

actor Mapper {
    
    func mapCryptoRecordToDTO(record: CKRecord) -> CryptocurrencyDTO? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let marketCap = record["marketCap"] as? Double,
              let logoString = record["logo"] as? String
        else {
            return nil
        }
        
        // Parsing SVG in the background
        let data = logoString.data(using: .utf8)
        // TODO: This is null for BTC the first time. I need to fix that somehow.
        let renderedLogoData: Data? = if let uiImage = SVGKImage(data: data)?.uiImage {
            uiImage.pngData()
        } else {
            nil
        }
        
        return CryptocurrencyDTO(
            id: id,
            name: name,
            value: value,
            marketCap: marketCap,
            renderedLogoData: renderedLogoData,
            favourite: false,
            sortOrder: nil
        )
    }
    
}
