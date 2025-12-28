import Foundation
import SwiftData

@MainActor
final class FiatRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAllFiat() -> [FiatCurrency] {
        if let fiatCurrencies = try? modelContext.fetch(FetchDescriptor<FiatCurrency>()) {
            return fiatCurrencies
        } else {
            print("Couldn't fetch fiat currencies. Returning an empty list instead.")
            return []
        }
    }

}

