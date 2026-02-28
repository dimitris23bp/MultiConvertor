import OSLog
import SwiftData
import SwiftUI

struct AddCurrenciesView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	@Query(
		sort: \Cryptocurrency.marketCap,
		order: .reverse,
		animation: .default
	) private var cryptocurrencies: [Cryptocurrency]

	@Query(sort: \FiatCurrency.popularity, order: .forward, animation: .default)
	private var fiatCurrencies: [FiatCurrency]

	private var isLoading: Bool {
		cryptocurrencies.count == initialCryptosSize
			|| fiatCurrencies.count == initialFiatSize
	}

	private var allCurrencies: [any Currency] {
		let all =
			(cryptocurrencies as [any Currency])
			+ (fiatCurrencies as [any Currency])
		return all.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
	}

	@State private var searchText: String = ""
	@State private var selectedTab: CurrencyTab = .crypto

	private var dynamicPredicateForCrypto: Predicate<Cryptocurrency> {
		#Predicate<Cryptocurrency> { crypto in
			if !searchText.isEmpty {
				crypto.id.localizedStandardContains(searchText)
					|| crypto.name.localizedStandardContains(searchText)
			} else {
				true
			}
		}
	}

	private var dynamicPredicateForFiat: Predicate<FiatCurrency> {
		#Predicate<FiatCurrency> { fiat in
			if !searchText.isEmpty {
				fiat.id.localizedStandardContains(searchText)
					|| fiat.name.localizedStandardContains(searchText)
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
						ForEach(
							(try! cryptocurrencies.filter(
								dynamicPredicateForCrypto
							))
						) { currency in
							AddCurrencyItemView(
								currency: currency,
								buttonPressed: buttonPressed(with:)
							)
						}
					} else {
						ForEach(
							(try! fiatCurrencies.filter(dynamicPredicateForFiat))
						) { currency in
							AddCurrencyItemView(
								currency: currency,
								buttonPressed: buttonPressed(with:)
							)
						}
					}
				}
				.scrollContentBackground(.hidden)
				.background(Color("MainColor"))
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
				}

				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						dismiss()
					}) {
						Image(systemName: "xmark")
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
			Log.ui.info("Currency \(currency.name) is a favourite")
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
	AddCurrenciesView()
		.modelContainer(Previews.preview)
}
