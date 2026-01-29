import CloudKit
import Foundation
import OSLog

final class Mapper: Sendable {
    
    private init() {}
    
    nonisolated static func mapCryptoRecordToDTO(record: CKRecord) -> CryptocurrencyDTO? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let marketCap = record["marketCap"] as? Double,
              let iconAsset = record["icon"] as? CKAsset
        else {
            return nil
        }

		let iconData = convertCKAssetToData(iconAsset)

        return CryptocurrencyDTO(
            id: id,
            name: name,
            value: value,
            marketCap: marketCap,
            iconData: iconData,
        )
    }
    
    nonisolated static func mapFiatRecordToDTO(record: CKRecord) -> FiatCurrencyDTO? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let popularity = record["order"] as? Int,
              let iconAsset = record["icon"] as? CKAsset
        else {
            return nil
        }

		let iconData = convertCKAssetToData(iconAsset)

        return FiatCurrencyDTO(
            id: id,
            name: name,
            value: value,
            iconData: iconData,
            popularity: popularity,
        )
    }

	nonisolated private static func convertCKAssetToData(_ asset: CKAsset) -> Data? {
		if let fileURL = asset.fileURL {
			do {
				return try Data(contentsOf: fileURL)
			} catch {
				Log.mapper.error("Error converting CKAsset to Data: \(error.localizedDescription)")
				return nil
			}
		} else {
			Log.mapper.error("Cannot convert CKAsset to Data: no fileURL")
			return nil
		}
	}
}
