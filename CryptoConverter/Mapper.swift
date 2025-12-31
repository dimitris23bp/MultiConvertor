import CloudKit
import SVGKit

actor Mapper {
    
    func mapCryptoRecordToDTO(record: CKRecord) -> CryptocurrencyDTO? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let marketCap = record["marketCap"] as? Double,
              let logoData = record["logo"] as? Data
        else {
            return nil
        }
        
        return CryptocurrencyDTO(
            id: id,
            name: name,
            value: value,
            marketCap: marketCap,
            iconData: logoData,
            favourite: false,
            sortOrder: nil
        )
    }
    
}
