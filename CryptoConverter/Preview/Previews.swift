import SwiftData
import Foundation
import SwiftUI

let schema: Schema = Schema([Cryptocurrency.self, FiatCurrency.self])

struct Previews {
    
	static var previewBtc: Cryptocurrency {
		Cryptocurrency(
			id: "BTC",
			name: "Bitcoin",
			value: 60000,
			marketCap: 6_000_000,
            iconData: nil
		)
	}

	static var previewEth: Cryptocurrency {
		Cryptocurrency(
			id: "ETH",
			name: "Ether",
			value: 20000,
			marketCap: 3_300_000,
            iconData: nil
		)
	}

    static var previewDot: Cryptocurrency {
        Cryptocurrency(
            id: "DOT",
            name: "Polkadot",
            value: 1500,
            marketCap: 2_250_000,
            iconData: nil
        )
    }
    
    static var previewEur: FiatCurrency {
        FiatCurrency(
            id: "EUR",
            name: "Euro",
            value: 0.80,
            iconData: nil,
            popularity: 1
        )
    }
    
    static var previewUsd: FiatCurrency {
        FiatCurrency(
            id: "USD",
            name: "US Dollar",
            value: 1,
            iconData: nil,
            popularity: 2
        )
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
