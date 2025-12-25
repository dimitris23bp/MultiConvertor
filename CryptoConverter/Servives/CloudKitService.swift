import CloudKit
import SVGKit

protocol CloudKitServiceProtocol {
    func fetchAllCryptocurrenciesFromCK() async -> [CryptocurrencyDTO]
    func fetchCryptocurrenciesFromCK(amount: Int) async throws -> [CryptocurrencyDTO]
}

actor CloudKitService : CloudKitServiceProtocol {
    
    nonisolated let publicDatabase = CKContainer.default().publicCloudDatabase

    func fetchAllCryptocurrenciesFromCK() async -> [CryptocurrencyDTO] {
        
        do {
            // Fetch the raw CKRecords
            let records = try await fetchAllPublicRecords()
            
            // Map records to DTOs
            let cryptos = records.compactMap { record in
                mapCryptoRecordToDTO(record: record)
            }
            return cryptos
        } catch {
            print("There was an error during fetching cryptos from CloudKit: \(error)")
            print("Returning an empty list instead")
            return []
        }
        
    }
    
    func fetchCryptocurrenciesFromCK(amount: Int) async throws -> [CryptocurrencyDTO] {
        do {
            // Fetch the raw CKRecords
            let records = try await fetchPublicRecords(withAmount: amount)
            
            // Map records to DTOs
            let cryptos = records.compactMap { record in
                mapCryptoRecordToDTO(record: record)
            }
            
            return cryptos
        } catch {
            print("There was an error during fetching cryptos from CloudKit: \(error)")
            print("Returning an empty list instead")
            return []
        }
    }
    
    private func mapCryptoRecordToDTO(record: CKRecord) -> CryptocurrencyDTO? {
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
        
        let favourite = record["favourite"] as? Bool ?? false
        let sortOrder = record["sortOrder"] as? Int
        
        return CryptocurrencyDTO(
            id: id,
            name: name,
            value: value,
            marketCap: marketCap,
            renderedLogoData: renderedLogoData,
            favourite: favourite,
            sortOrder: sortOrder
        )
    }
    
    /// Fetches all records of a specific type, regardless of count.
    /// Uses cursor for batches, because CloudKit cannot handle more than 250 records in one query.
    private func fetchAllPublicRecords() async throws -> [CKRecord] {
        var allRecords: [CKRecord] = []
        var currentCursor: CKQueryOperation.Cursor? = nil
        
        let query = CKQuery(recordType: "Cryptocurrency", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "marketCap", ascending: false)]
        
        repeat {
            let (results, nextCursor): ([(CKRecord.ID, Result<CKRecord, Error>)], CKQueryOperation.Cursor?)
            
            if let cursor = currentCursor {
                // Fetch the next batch using the cursor
                (results, nextCursor) = try await publicDatabase.records(continuingMatchFrom: cursor)
            } else {
                // Initial fetch
                (results, nextCursor) = try await publicDatabase.records(matching: query)
            }
            
            // Extract the records from the results tuple
            let records = results.compactMap { (id, result) -> CKRecord? in
                switch result {
                case .success(let record):
                    return record
                case .failure(let error):
                    print("Error fetching individual record \(id): \(error)")
                    return nil
                }
            }
            
            allRecords.append(contentsOf: records)
            currentCursor = nextCursor // Update the cursor for the next iteration
            
        } while currentCursor != nil
        
        return allRecords
    }
    
    /// Fetches all records of a specific type, regardless of count.
    private func fetchPublicRecords(withAmount amount: Int) async throws -> [CKRecord] {
        guard amount > 0  && amount <= 250 else {
            print("The amount cannot be less than 1 or more than 250")
            return []
        }
        var allRecords: [CKRecord] = []
        
        let query = CKQuery(recordType: "Cryptocurrency", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "marketCap", ascending: false)]
        
        let (results, _) = try await publicDatabase.records(matching: query, resultsLimit: amount)
        
        // Extract the records from the results tuple
        let records = results.compactMap { (id, result) -> CKRecord? in
            switch result {
            case .success(let record):
                return record
            case .failure(let error):
                print("Error fetching individual record \(id): \(error)")
                return nil
            }
        }
        
        allRecords.append(contentsOf: records)
        
        return allRecords
    }
}
