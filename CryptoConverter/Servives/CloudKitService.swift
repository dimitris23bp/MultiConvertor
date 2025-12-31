import CloudKit
import SVGKit

protocol CloudKitServiceProtocol: Sendable {
    func fetchAllCryptocurrenciesFromCK() async -> [CryptocurrencyDTO]
    func fetchAllFiatCurrenciesFromCK() async -> [FiatCurrencyDTO]
    func fetchCryptocurrenciesFromCK(amount: Int) async throws -> [CryptocurrencyDTO]
    func fetchFiatCurrenciesFromCK(amount: Int) async throws -> [FiatCurrencyDTO]
	func getLastUpdate() async -> Date?
}

actor CloudKitService : CloudKitServiceProtocol {
    
    nonisolated let publicDatabase = CKContainer.default().publicCloudDatabase
    private let mapper = Mapper()

    func fetchAllFiatCurrenciesFromCK() async -> [FiatCurrencyDTO] {
        do {
            // Fetch the raw CKRecords
            let records = try await fetchAllPublicRecords(ofType: "FiatCurrency", withSortDescriptor: "order")
            
            // Map records to DTOs
            let fiats = records.compactMap { record in
                mapFiatRecordToDTO(record: record)
            }
            return fiats
        } catch {
            print("There was an error during fetching fiats from CloudKit: \(error)")
            print("Returning an empty list instead")
            return []
        }
        
    }
    
    func fetchAllCryptocurrenciesFromCK() async -> [CryptocurrencyDTO] {
        do {
            // Fetch the raw CKRecords
            let records = try await fetchAllPublicRecords(ofType: "Cryptocurrency", withSortDescriptor: "marketCap")
            
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
    
    func fetchFiatCurrenciesFromCK(amount: Int) async -> [FiatCurrencyDTO] {
        do {
            // Fetch the raw CKRecords
            let records = try await fetchPublicRecords(ofType: "FiatCurrency", withSortDescriptor: "order", withAscending: true, withAmount: amount)
            
            // Map records to DTOs
            let fiats = records.compactMap { record in
                mapFiatRecordToDTO(record: record)
            }
            return fiats
        } catch {
            print("There was an error during fetching fiats from CloudKit: \(error)")
            print("Returning an empty list instead")
            return []
        }
    }
    
    func fetchCryptocurrenciesFromCK(amount: Int) async throws -> [CryptocurrencyDTO] {
        do {
            // Fetch the raw CKRecords
            let records = try await fetchPublicRecords(ofType: "Cryptocurrency", withSortDescriptor: "marketCap", withAscending: false, withAmount: amount)
            
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
    
    func getLastUpdate() async -> Date? {
		let query = CKQuery(recordType: "Cryptocurrency", predicate: NSPredicate(value: true))
		query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]

		do {
			let (results, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)
			if let (_, result) = results.first, case .success(let record) = result {
				return record.modificationDate
			}
		} catch {
			print("Error fetching last update date: \(error)")
		}
		return nil
    }
    
    
    /// Fetches all records of a specific type, regardless of count.
    /// Uses cursor for batches, because CloudKit cannot handle more than 250 records in one query.
    private func fetchAllPublicRecords(ofType type: String, withSortDescriptor descriptor: String) async throws -> [CKRecord] {
        var allRecords: [CKRecord] = []
        var currentCursor: CKQueryOperation.Cursor? = nil
        
        let query = CKQuery(recordType: type, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: descriptor, ascending: false)]
        
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
    private func fetchPublicRecords(ofType type: String, withSortDescriptor descriptor: String, withAscending ascending: Bool, withAmount amount: Int) async throws -> [CKRecord] {
        guard amount > 0  && amount <= 250 else {
            print("The amount cannot be less than 1 or more than 250")
            return []
        }
        var allRecords: [CKRecord] = []
        
        let query = CKQuery(recordType: type, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: descriptor, ascending: ascending)]
        
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
    
    // TODO: To move mappers later
    private func mapCryptoRecordToDTO(record: CKRecord) -> CryptocurrencyDTO? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let marketCap = record["marketCap"] as? Double,
              let logoString = record["logo"] as? String
        else {
            return nil
        }
        
        return CryptocurrencyDTO(
            id: id,
            name: name,
            value: value,
            marketCap: marketCap,
            iconString: logoString,
            favourite: false,
            sortOrder: nil
        )
    }
    
    private func mapFiatRecordToDTO(record: CKRecord) -> FiatCurrencyDTO? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let value = record["value"] as? Double,
              let popularity = record["order"] as? Int,
              let flagString = record["flag"] as? String
        else {
            return nil
        }
        
        return FiatCurrencyDTO(
            id: id,
            name: name,
            value: value,
            iconString: flagString,
            favourite: false,
            popularity: popularity,
            sortOrder: nil
        )
    }
}
