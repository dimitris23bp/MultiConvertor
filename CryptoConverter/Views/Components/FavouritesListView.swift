import SwiftUI
import SwiftData

struct FavouritesListView: View {
    enum CurrencyType { case fiat, crypto }

    var favouriteCryptos: [Cryptocurrency]
    var favouriteFiats: [FiatCurrency]
    var displayMode: DisplayMode
    @Binding var editMode: EditMode
    @Binding var selection: Set<String>
    @Binding var amounts: [String: Double]
    var onFocusChange: (String?, Bool) -> Void
    var scrollProxy: ScrollViewProxy?

    var onDelete: (any Currency) -> Void
    var onMoveMerged: (IndexSet, Int) -> Void
    var onMoveSeparated: (IndexSet, Int, CurrencyType) -> Void
    var updateInputs: (String, Double) -> Void
	var lastUpdate: String

	private var numberFormatter: NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = Locale.current
		formatter.maximumFractionDigits = 8
		return formatter
	}

    private var combinedFavourites: [any Currency] {
        let all = (favouriteCryptos as [any Currency]) + (favouriteFiats as [any Currency])
        return all.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
    }

    var body: some View {
        List {
            if displayMode == .merged {
                Section {
                    ForEach(combinedFavourites, id: \.id) { currency in
						currencyItemView(for: currency)
                    }
                    .onMove(perform: onMoveMerged)

				} footer: {
					Text("Last updated: \(lastUpdate)")
				}
            } else {
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

                Section {
                    ForEach(favouriteCryptos, id: \.id) { currency in
						currencyItemView(for: currency)
                    }
                    .onMove(perform: { source, destination in
                        onMoveSeparated(source, destination, .crypto)
                    })
				} header: {
					Text("Crypto Currencies")

				} footer: {
					Text("Last updated: \(lastUpdate)")
				}
            }
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
			numberFormatter: numberFormatter,
			onFocusChange: { isFocused in
				onFocusChange(currency.id, isFocused)
			},
			scrollProxy: scrollProxy,
			onTap: handleCurrencyTap,
			onDelete: onDelete)

	}

	private func handleCurrencyTap(
		for currency: any Currency,
	) {
		if selection.contains(currency.id) {
			selection.remove(currency.id)
		} else {
			selection.insert(currency.id)
		}
	}
}
