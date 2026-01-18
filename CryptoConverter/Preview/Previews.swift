import SwiftData
import Foundation
import SwiftUI

let schema: Schema = Schema([Cryptocurrency.self, FiatCurrency.self])

struct Previews {
    
	static var previewBtc: Cryptocurrency {
		let currency = Cryptocurrency(
			id: "BTC",
			name: "Bitcoin",
			value: 60000,
			marketCap: 6_000_000,
            iconData: nil
		)
		currency .favourite = true
        return currency
	}

	static var previewEth: Cryptocurrency {
		let currency = Cryptocurrency(
			id: "ETH",
			name: "Ether",
			value: 20000,
			marketCap: 3_300_000,
            iconData: nil
		)
		currency.favourite = true
		return currency
	}

    static var previewDot: Cryptocurrency {
        let currency = Cryptocurrency(
            id: "DOT",
            name: "Polkadot",
            value: 1500,
            marketCap: 2_250_000,
            iconData: nil
        )
		currency.favourite = true
		return currency
    }
    
    static var previewEur: FiatCurrency {
        let currency = FiatCurrency(
            id: "EUR",
            name: "Euro",
            value: 0.80,
            popularity: 1,
            iconData: nil
        )
		currency.favourite = true
		return currency
    }
    
    static var previewUsd: FiatCurrency {
        let currency = FiatCurrency(
            id: "USD",
            name: "US Dollar",
            value: 1,
            popularity: 2,
            iconData: nil
        )
        currency.favourite = true
        return currency
    }
    
    // The sample preview db
    static let preview: ModelContainer = {
        let container = try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		container.mainContext.insert(previewBtc)
		container.mainContext.insert(previewEth)
        container.mainContext.insert(previewDot)

        container.mainContext.insert(previewEur)
        container.mainContext.insert(previewUsd)
        
		return container
	}()
}
