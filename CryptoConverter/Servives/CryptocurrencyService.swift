import CloudKit

final class CryptocurrencyService : Sendable {
    // Ensure your init is not restricted to the MainActor
    init() {}
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    func fetchAllCryptocurrencies() async throws -> [Cryptocurrency] {
        
        // Fetch the raw CKRecords
        let records = try await fetchAllPublicRecords()
        
        // Map records to model objects
        // compactMap automatically removes any 'nil' results if a record is malformed
        let cryptos = records.compactMap { record in
            Cryptocurrency(record: record)
        }
        
        return cryptos
    }
    
    // TODO: Get the ones with the highest marketCap
    func fetchCryptocurrencies(amount: Int) async throws -> [Cryptocurrency] {
        // Fetch the raw CKRecords
        let records = try await fetchPublicRecords(withAmount: amount)
        
        // Map records to model objects
        // compactMap automatically removes any 'nil' results if a record is malformed
        let cryptos = records.compactMap { record in
            Cryptocurrency(record: record)
        }
        
        return cryptos
    }
    
    /// Fetches all records of a specific type, regardless of count.
    /// Uses cursor for batches, because CloudKit cannot handle more than 250 records in one query.
    private func fetchAllPublicRecords() async throws -> [CKRecord] {
        var allRecords: [CKRecord] = []
        var currentCursor: CKQueryOperation.Cursor? = nil
        
        let query = CKQuery(recordType: "Cryptocurrency", predicate: NSPredicate(value: true))
        
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
    
    // TODO: Make sure amount is maximum 250
    /// Fetches all records of a specific type, regardless of count.
    private func fetchPublicRecords(withAmount amount: Int) async throws -> [CKRecord] {
        var allRecords: [CKRecord] = []
        
        let query = CKQuery(recordType: "Cryptocurrency", predicate: NSPredicate(value: true))
        
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
