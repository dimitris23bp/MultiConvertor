//
//  CryptocurrencyService.swift
//  CryptoConverter
//
//  Created by Dimitrios Karamanis on 21/12/2025.
//

import XCTest
@testable import CryptoConverter
import CloudKit

final class CloudKitTests: XCTestCase {

    func testFetchAllRecords() async throws {
        let manager = await CryptocurrencyService()
        
        // Use an expectation to handle the async nature of the call
        do {
            let records = try await manager.fetchAllPublicRecords()
            
            // This is where you verify the results
            XCTAssertFalse(records.isEmpty, "The public database should not be empty.")
            print("Successfully fetched \(records.count) records.")
            
            for record in records.prefix(5) { // Print first 5 for sanity check
                print("Record ID: \(record.recordID.recordName)")
            }
        } catch {
            XCTFail("Fetch failed with error: \(error.localizedDescription)")
        }
    }
}
