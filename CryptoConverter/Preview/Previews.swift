import SwiftData
import Foundation
import SwiftUI

struct Previews {
    
	static var previewBtc: Cryptocurrency {
		Cryptocurrency(
			id: "BTC",
			name: "Bitcoin",
			value: 60000,
			marketCap: 6_000_000,
            // TODO: To fix this preview
            logoString: "preview"
		)
	}

	static var previewEth: Cryptocurrency {
		Cryptocurrency(
			id: "ETH",
			name: "Ether",
			value: 20000,
			marketCap: 3_300_000,
            logoString: "preview"
		)
	}

    static var previewDot: Cryptocurrency {
        Cryptocurrency(
            id: "DOT",
            name: "Polkadot",
            value: 1500,
            marketCap: 2_250_000,
            logoString: "preview"
        )
    }
    // The sample preview db
    static let preview: ModelContainer = {
        let container = try! ModelContainer(for: Cryptocurrency.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		container.mainContext.insert(previewBtc)
		container.mainContext.insert(previewEth)
        container.mainContext.insert(previewDot)

		return container
	}()
}
