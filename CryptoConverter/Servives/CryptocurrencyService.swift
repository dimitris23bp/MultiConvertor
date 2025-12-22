import CloudKit

actor CryptocurrencyService {
    // Ensure your init is not restricted to the MainActor
    init() {}
    
    nonisolated let publicDatabase = CKContainer.default().publicCloudDatabase
    
    func fetchAllCryptocurrencies() async -> [Cryptocurrency] {
        
        do {
            // Fetch the raw CKRecords
            let records = try await fetchAllPublicRecords()
            
            // Map records to model objects
            // compactMap automatically removes any 'nil' results if a record is malformed
            let cryptos = records.compactMap { record in
                Cryptocurrency(record: record)
            }
            return cryptos
        } catch {
            print("There was an error during fetching cryptos from CloudKit: \(error)")
            print("Returning an empty list instead")
            return []
        }
        
    }
    
    func fetchCryptocurrencies(amount: Int) async throws -> [Cryptocurrency] {
        do {
            // Fetch the raw CKRecords
            let records = try await fetchPublicRecords(withAmount: amount)
            
            // Map records to model objects
            // compactMap automatically removes any 'nil' results if a record is malformed
            let cryptos = records.compactMap { record in
                Cryptocurrency(record: record)
            }
            
            return cryptos
        } catch {
            print("There was an error during fetching cryptos from CloudKit: \(error)")
            print("Returning an empty list instead")
            return []
        }
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
