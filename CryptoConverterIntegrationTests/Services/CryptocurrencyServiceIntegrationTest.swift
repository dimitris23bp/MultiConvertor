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
        let manager = CryptocurrencyService()
        
        // Use an expectation to handle the async nature of the call
        do {
            let cryptos = try await manager.fetchCryptocurrenciesFromCK(amount: 50)
            
            // This is where you verify the results
            XCTAssertFalse(cryptos.isEmpty, "The public database should not be empty.")
            print("Successfully fetched \(cryptos.count) records.")
            
            for crypto in cryptos.prefix(5) { // Print first 5 for sanity check
                print("Record ID: \(crypto.name)")
            }
        } catch {
            XCTFail("Fetch failed with error: \(error.localizedDescription)")
        }
    }
}
