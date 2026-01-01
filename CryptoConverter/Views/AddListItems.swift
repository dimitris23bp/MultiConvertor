import SwiftUI
import SwiftData

struct AddListItems: View {
    @Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	@Query(sort: \Cryptocurrency.marketCap, order: .reverse, animation: .default) private var cryptocurrencies: [Cryptocurrency]

    @Query(sort: \FiatCurrency.popularity, order: .forward, animation: .default) private var fiatCurrencies: [FiatCurrency]
    
    private var allCurrencies: [any Currency] {
        let all = (cryptocurrencies as [any Currency]) + (fiatCurrencies as [any Currency])
        return all.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
    }

	@State private var searchText: String = ""
	@State private var selectedTab: CurrencyTab = .crypto
	
	let imageSize: CGFloat

	private var dynamicPredicateForCrypto: Predicate<Cryptocurrency> {
		#Predicate<Cryptocurrency> { crypto in
			if !searchText.isEmpty {
				crypto.id.localizedStandardContains(searchText) || crypto.name.localizedStandardContains(searchText)
			} else {
				true
			}
		}
	}

    private var dynamicPredicateForFiat: Predicate<FiatCurrency> {
        #Predicate<FiatCurrency> { fiat in
            if !searchText.isEmpty {
                fiat.id.localizedStandardContains(searchText) || fiat.name.localizedStandardContains(searchText)
            } else {
                true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
					if selectedTab == .crypto {
                        ListCategory(currencies: cryptocurrencies, dynamicPredicate: dynamicPredicateForCrypto, imageSize: imageSize, buttonPressed: buttonPressed(with:))
					} else {
                        ListCategory(currencies: fiatCurrencies, dynamicPredicate: dynamicPredicateForFiat, imageSize: imageSize, buttonPressed: buttonPressed(with:))
					}
                }
            }
			.searchable(text: $searchText)
			.animation(.default, value: searchText)
            .toolbar {
				ToolbarItem(placement: .principal) {
					Picker("Currency Type", selection: $selectedTab) {
						Text("Crypto").tag(CurrencyTab.crypto)
						Text("Fiat").tag(CurrencyTab.fiat)
					}
                    .pickerStyle(.segmented)
//					.frame(maxWidth: 200)
				}
				
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func buttonPressed(with currency: Currency) {
        if currency.favourite == false {
            let highestOrder = allCurrencies.getHighestOrder()
            currency.sortOrder = highestOrder + 1
            currency.favourite = true
        } else {
            currency.sortOrder = nil
            currency.favourite = false
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context after reorder: \(error)")
        }
    }
}

enum CurrencyTab {
	case crypto
	case fiat
}

#Preview {
    AddListItems(imageSize: 48)
        .modelContainer(Previews.preview)
}
