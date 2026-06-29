import OSLog
import SwiftData
import SwiftUI

struct FavouritesListView: View {
	enum CurrencyType { case fiat, crypto }
	@Query(
		filter: #Predicate<Cryptocurrency> { $0.favourite },
		sort: \.sortOrder,
		animation: .default
	) private var favouriteCryptos: [Cryptocurrency]

	@Query(
		filter: #Predicate<FiatCurrency> { $0.favourite },
		sort: \.sortOrder,
		animation: .default
	) private var favouriteFiats: [FiatCurrency]

	@Query private var appSettings: [AppSettings]

	var displayMode: DisplayMode
	@Binding var editMode: EditMode
	@Binding var selection: Set<String>
	@Binding var amounts: [String: Double]
	var focusedCurrencyId: FocusState<String?>.Binding

	var onDelete: (any Currency) -> Void
	var onMoveMerged: (IndexSet, Int) -> Void
	var onMoveSeparated: (IndexSet, Int, CurrencyType) -> Void
	var updateInputs: (String, Double) -> Void

	private func logFavouritesChange() {
		let cryptoInfo = favouriteCryptos.map { "\($0.id):\($0.name)" }.joined(
			separator: ", "
		)
		let fiatInfo = favouriteFiats.map { "\($0.id):\($0.name)" }.joined(
			separator: ", "
		)

		Log.ui.infoApp(
			"Favourite cryptos changed: \(favouriteCryptos.count) items - \(cryptoInfo)"
		)
		Log.ui.infoApp(
			"Favourite fiats changed: \(favouriteFiats.count) items - \(fiatInfo)"
		)

		let combinedInfo = combinedFavourites.map { "\($0.id):\($0.name)" }
			.joined(separator: ", ")
		Log.ui.infoApp(
			"Combined favourites: \(combinedFavourites.count) items - \(combinedInfo)"
		)
	}

	private var combinedFavourites: [any Currency] {
		let all =
			(favouriteCryptos as [any Currency])
			+ (favouriteFiats as [any Currency])
		return all.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
	}

	var body: some View {
		List {
			if displayMode == .merged {
				if !combinedFavourites.isEmpty {
					Section {
						ForEach(combinedFavourites, id: \.id) { currency in
							currencyItemView(for: currency)
						}
						.onMove(perform: onMoveMerged)
					}
				} else {
					NoCurrenciesView()
				}
			} else {
				if !favouriteFiats.isEmpty {
					Section {
						ForEach(favouriteFiats, id: \.id) { currency in
							currencyItemView(for: currency)
						}
						.onMove(perform: { source, destination in
							onMoveSeparated(source, destination, .fiat)
						})
					} header: {
						Text("Fiat Currencies")
					}
				}

				if !favouriteCryptos.isEmpty {
					Section {
						ForEach(favouriteCryptos, id: \.id) { currency in
							currencyItemView(for: currency)
						}
						.onMove(perform: { source, destination in
							onMoveSeparated(source, destination, .crypto)
						})
					} header: {
						Text("Crypto Currencies")
					}
				}

				if combinedFavourites.isEmpty {
					NoCurrenciesView()
				}
			}
		}
		.scrollContentBackground(.hidden)
		.background(Color("MainColor"))
		.onChange(of: favouriteCryptos) { _, _ in
			logFavouritesChange()
		}
		.onChange(of: favouriteFiats) { _, _ in
			logFavouritesChange()
		}
	}

	private func getAmountOfDecimals(for currency: any Currency) -> Int {
		if currency is Cryptocurrency {
			return appSettings.first?.cryptoDecimals ?? 8
		} else {
			return appSettings.first?.fiatDecimals ?? 8
		}
	}

	private func currencyItemView(for currency: any Currency) -> some View {
		CurrencyItemView(
			currency: currency,
			editMode: $editMode,
			selection: $selection,
			amount: Binding(
				get: { amounts[currency.id] ?? 0.0 },
				set: { newValue in
					amounts[currency.id] = newValue
					updateInputs(currency.id, newValue)
				}
			),
			updateInputs: updateInputs,
			decimals: getAmountOfDecimals(for: currency),
			isFocused: focusedCurrencyId.wrappedValue == currency.id,
			onTap: handleCurrencyTap,
			onDelete: onDelete
		)
		.focused(focusedCurrencyId, equals: currency.id)

	}

	private func handleCurrencyTap(
		for currency: any Currency,
	) {
		if editMode.isEditing {
			if selection.contains(currency.id) {
				selection.remove(currency.id)
			} else {
				selection.insert(currency.id)
			}
		} else {
			focusedCurrencyId.wrappedValue = currency.id
		}
	}
}
