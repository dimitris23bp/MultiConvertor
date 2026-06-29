import SwiftUI
import SwiftData
import Foundation


struct OverviewView: View {
	@Environment(\.scenePhase) private var scenePhase
	@Environment(\.modelContext) private var modelContext

	let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

	@Query private var appSettings: [AppSettings]

	private var displayMode: DisplayMode {
		appSettings.first?.displayMode ?? .merged
	}

	@Query(sort: \Cryptocurrency.sortOrder, animation: .default) private var cryptocurrencies: [Cryptocurrency]

	@Query(
		filter: #Predicate<Cryptocurrency> { $0.favourite },
		sort: \.sortOrder,
		animation: .default
	) private var favouriteCryptos: [Cryptocurrency]

	@Query(sort: \FiatCurrency.popularity, animation: .default) private var fiatCurrencies: [FiatCurrency]

	@Query(
		filter: #Predicate<FiatCurrency> { $0.favourite },
		sort: \.sortOrder,
		animation: .default
	) private var favouriteFiats: [FiatCurrency]

	private var combinedFavourites: [any Currency] {
		let all = (favouriteCryptos as [any Currency]) + (favouriteFiats as [any Currency])
		return all.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
	}

	@ObservedObject var scheduler: TickerUpdateScheduler

	@State private var amounts: [String: Double] = [:]
	@State private var editMode: EditMode = .inactive
	@State private var selection = Set<String>()
	@State private var isShowingSheet = false
	@FocusState private var focusedCurrencyId: String?

	var body: some View {
		NavigationStack {
			ScrollViewReader { proxy in
				FavouritesListView(
					displayMode: displayMode,
					editMode: $editMode,
					selection: $selection,
					amounts: $amounts,
					focusedCurrencyId: $focusedCurrencyId,
					onDelete: { currency in
						currency.favourite = false
					},
					onMoveMerged: moveItemsMerged,
					onMoveSeparated: moveItemsSeparated,
					updateInputs: updateInputs
				)
				.scrollDismissesKeyboard(.interactively)
				.toolbar {
					ToolbarItemGroup(placement: .topBarTrailing) {

						Button(action: {
							withAnimation {
								if editMode == .active {
									editMode = .inactive
									selection.removeAll()
								} else {
									editMode = .active
								}
							}
						}) {
							Image(systemName: editMode.isEditing ? "pencil.slash" : "pencil")
						}
						.disabled(combinedFavourites.isEmpty)

						Button(action: {
							isShowingSheet.toggle()
						}) {
							Image(systemName: "plus")
						}
						.sheet(isPresented: $isShowingSheet) {
							AddCurrenciesView()
						}
						.onChange(of: isShowingSheet) { _, newValue in
							if newValue {
								print("Focus is removed")

								// In order to remove the focused value too, when I press the plus button
								focusedCurrencyId = nil
								Task {
									// To have a delay and make the change without the user noticing
									try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

									// Empty all the values from the TextFields
									amounts = [:]

									// Remove all fields from the checkboxes
									selection.removeAll()

									// Remove editting mode
									editMode = .inactive
								}
							}
						}
					}

					// Bottom bar in edit mode
					if editMode.isEditing {
						ToolbarItemGroup(placement: .bottomBar) {
							Spacer()
							Button(role: .destructive) {
								deleteSelectedItems()
							} label: {
								Text("Delete (\(selection.count)) Selected")
							}
							.disabled(selection.isEmpty)
						}
					}
				}
				.environment(\.editMode, $editMode)
				.toolbar(editMode.isEditing ? .hidden : .visible, for: .tabBar)
				.onChange(of: focusedCurrencyId) { _, newId in
					print("New scrolling")
					if let id = newId {
						print("Inside new scrolling")
						DispatchQueue.main.async {
							withAnimation {
								proxy.scrollTo(id, anchor: .center)
							}
						}
					}
				}
				.padding(.top, -5)
			}
		}.onChange(of: scenePhase, { _, newValue in
			if newValue != .active {
				focusedCurrencyId = nil
			}
		})
	}

	private func moveItemsMerged(from source: IndexSet, to destination: Int) {
		var reorderedCurrencies = combinedFavourites
		reorderedCurrencies.move(fromOffsets: source, toOffset: destination)

		for (index, currency) in reorderedCurrencies.enumerated() {
			currency.sortOrder = index
		}
		do {
			try modelContext.save()
		} catch {
			print("Failed to save context after reorder: \(error)")
		}
	}

	private func moveItemsSeparated(from source: IndexSet, to destination: Int, in listType: FavouritesListView.CurrencyType) {
		let listToReorder: [any Currency]
		let otherList: [any Currency]

		if listType == .fiat {
			listToReorder = favouriteFiats
			otherList = favouriteCryptos
		} else {
			listToReorder = favouriteCryptos
			otherList = favouriteFiats
		}

		var reorderedSublist = listToReorder
		reorderedSublist.move(fromOffsets: source, toOffset: destination)

		var newCombinedList: [any Currency] = []

		// Get iterators so I can change the "global" sortOrder, and not only the source (IndexSet) that `onMove` gives me
		var reorderedSublistIterator = reorderedSublist.makeIterator()
		var otherListIterator = otherList.makeIterator()

		for currency in combinedFavourites {
			if (currency is FiatCurrency && listType == .fiat) || (currency is Cryptocurrency && listType == .crypto) {
				if let next = reorderedSublistIterator.next() {
					newCombinedList.append(next)
				}
			} else {
				if let next = otherListIterator.next() {
					newCombinedList.append(next)
				}
			}
		}

		for (index, currency) in newCombinedList.enumerated() {
			currency.sortOrder = index
		}

		do {
			try modelContext.save()
		} catch {
			print("Failed to save context after reorder: \(error)")
		}
	}

	private func updateInputs(basedOn currencyId: String, with value: Double) {
		// Find the source currency in either list
		let sourceCurrency: (any Currency)? = cryptocurrencies.first(where: { $0.id == currencyId })
		?? fiatCurrencies.first(where: { $0.id == currencyId })

		guard let source = sourceCurrency else { return }

		for currency in combinedFavourites {
			if currency.id == source.id {
				amounts[currency.id] = value
			} else {
				let sourcePrice = priceInUSD(for: source)
				let targetPrice = priceInUSD(for: currency)

				if targetPrice != 0 {
					let valueDouble = (sourcePrice * value) / targetPrice
					amounts[currency.id] = valueDouble
				} else {
					amounts[currency.id] = 0
				}
			}
		}
	}

	private func priceInUSD(for currency: any Currency) -> Double {
		if let _ = currency as? FiatCurrency {
			// Fiat value is units per USD. Price in USD is 1 / value.
			return currency.value > 0 ? 1.0 / currency.value : 0.0
		} else {
			// Crypto value is USD per unit.
			return currency.value
		}
	}

	private func deleteSelectedItems() {
		withAnimation {
			for id in selection {
				if let crypto = favouriteCryptos.first(where: { $0.id == id }) {
					crypto.favourite = false
				} else if let fiat = favouriteFiats.first(where: { $0.id == id }) {
					fiat.favourite = false
				}
			}
			selection.removeAll()
			editMode = .inactive
		}
	}

}

#Preview {
	OverviewView(scheduler: TickerUpdateScheduler())
		.modelContainer(Previews.preview)
}
