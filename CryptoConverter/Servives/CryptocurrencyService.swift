//
//  CryptocurrencyService.swift
//  CryptoConverter
//
//  Created by Dimitrios Karamanis on 21/12/2025.
//

import CloudKit

class CryptocurrencyService {
    let publicDatabase = CKContainer.default().publicCloudDatabase

    /// Fetches all records of a specific type, regardless of count.
    func fetchAllPublicRecords() async throws -> [CKRecord] {
        var allRecords: [CKRecord] = []
        var currentCursor: CKQueryOperation.Cursor? = nil
        
        // Define your query
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
        print("Here we come")
        print(allRecords)
        return allRecords
        
    }
}
