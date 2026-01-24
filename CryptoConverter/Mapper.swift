import CloudKit
import Foundation

final class Mapper: Sendable {
    
    private init() {}
    
    nonisolated static func mapCryptoRecordToDTO(record: CKRecord) -> CryptocurrencyDTO? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let marketCap = record["marketCap"] as? Double,
              let logoData = record["icon"] as? Data
        else {
            return nil
        }
        
        return CryptocurrencyDTO(
            id: id,
            name: name,
            value: value,
            marketCap: marketCap,
            iconData: logoData,
        )
    }
    
    nonisolated static func mapFiatRecordToDTO(record: CKRecord) -> FiatCurrencyDTO? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let popularity = record["order"] as? Int,
              let flagData = record["icon"] as? Data
        else {
            return nil
        }
        
        return FiatCurrencyDTO(
            id: id,
            name: name,
            value: value,
            iconData: flagData,
            popularity: popularity,
        )
    }
}
