import SwiftUI
import SwiftData

struct InputValues {
	// Store the trimmed value 1.23456789 will be "1.234567"
	var amountString: String
	// Stores the real value, to be precise in calculations
	var amountDouble: Double
}

struct OverviewView: View {
	@Environment(\.scenePhase) private var scenePhase
	@Environment(\.modelContext) private var modelContext
    
    let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

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

    private var allCurrencies: [any Currency] {
        let all = (cryptocurrencies as [any Currency]) + (fiatCurrencies as [any Currency])
        return all.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
    }
    
    private var currencyService: CurrencyService {
        let repoCrypto = CryptoRepository(modelContext: modelContext)
        let repoFiat = FiatRepository(modelContext: modelContext)
        let repoAll = AllRepository(modelContext: modelContext, cryptoRepo: repoCrypto, fiatRepo: repoFiat)
        
        let cloudKitService = CloudKitService()
        
        let cryptoService = CryptocurrencyService(repository: repoCrypto, cloudKitService: cloudKitService)
        let fiatService = FiatCurrencyService(fiatRepository: repoFiat, cloudkitService: cloudKitService)
        return CurrencyService(fiatService: fiatService, cryptoService: cryptoService, currencyRepository: repoAll)
    }

	@ObservedObject var scheduler: TickerUpdateScheduler

	@State private var amounts: [String: Double] = [:]
	@State private var editMode: EditMode = .inactive
    @State private var selection = Set<String>()
	@State private var isShowingSheet = false
    @State private var lastUpdate: String = "NaN"
	// No need for @FocusState, because it is handled inside the DoubleNumberTextField
	@State private var focusedCurrencyId: String? = nil

	let imageSize: CGFloat = 42
	
	private var numberFormatter: NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = Locale.current
		formatter.maximumFractionDigits = 8
		return formatter
	}

	var body: some View {
		NavigationSplitView {
			List {
				Section {
					ForEach(combinedFavourites, id: \.id) { currency in
						HStack {
							if editMode.isEditing {
								Button(action: {
									if selection.contains(currency.id) {
										selection.remove(currency.id)
									} else {
										selection.insert(currency.id)
									}
								}) {
									Image(systemName: selection.contains(currency.id) ? "checkmark.square.fill" : "square")
								}
							}

							Image(uiImage: currency.icon ?? UIImage())
								.resizable()
								.scaledToFit()
								.frame(width: imageSize, height: imageSize)

							VStack(alignment: .leading) {
								Text("\(currency.id)")
									.minimumScaleFactor(0.75)
									.lineLimit(1)
								Text("\(currency.name)")
									.minimumScaleFactor(0.75)
									.lineLimit(1)
							}
							.padding()

							Spacer()

							ScrollView(.horizontal, showsIndicators: false) {
								DoubleNumberTextField(
									value: Binding(
										get: { amounts[currency.id] ?? 0.0 },
										set: { newValue in
											amounts[currency.id] = newValue
											updateInputs(basedOn: currency.id, with: newValue)
										}
									),
									formatter: numberFormatter,
									isFocused: Binding(
										get: { focusedCurrencyId == currency.id },
										set: { newValue in
											if newValue {
												focusedCurrencyId = currency.id
											} else if focusedCurrencyId == currency.id {
												focusedCurrencyId = nil
											}
										}
									)
								)
								.id(currency.id)
								.frame(height: 40)
								.fixedSize(horizontal: true, vertical: false)
							}
							.frame(maxWidth: 150)
							.fixedSize(horizontal: true, vertical: false)
							.padding(.horizontal, 10)
							.background(
								RoundedRectangle(cornerRadius: 6)
									.fill(focusedCurrencyId == currency.id ? Color.secondary.opacity(0.2) : Color.clear)
							)
							.animation(.easeOut(duration: 0.1), value: focusedCurrencyId == currency.id)
							.tint(Color.clear)
							.minimumScaleFactor(0.75)
						}
						// Make sure there are not "transparent" places like the Spacers that my tapGesture won't be registered
						.contentShape(Rectangle())
						// Tap Gesture to handle the click of an item, the openning of the keyboard, etc.
						.onTapGesture {
							if editMode.isEditing {
								if selection.contains(currency.id) {
									selection.remove(currency.id)
								} else {
									selection.insert(currency.id)
								}
							} else {
								focusedCurrencyId = currency.id
							}
						}
						.swipeActions(edge: .trailing) {
							Button(role: .destructive, action: {
								currency.favourite = false
							}) {
								Label("Delete", systemImage: "trash")
							}
						}
					}
					.onMove(perform: moveItems)
				} footer: {
					Text("Last updated: \(lastUpdate)")
				}
			}
			.scrollDismissesKeyboard(.interactively)
			.toolbar {
				ToolbarItemGroup(placement: .navigationBarTrailing) {
					Button(action: {
						withAnimation {
							editMode = editMode.isEditing ? .inactive : .active
						}
					}) {
						Image(systemName: editMode.isEditing ? "pencil.slash" : "pencil")
					}
					Button(action: {
						isShowingSheet.toggle()
					}) {
						Image(systemName: "plus")
					}
					.sheet(isPresented: $isShowingSheet) {
						AddListItems(imageSize: imageSize)
					}
					.onChange(of: isShowingSheet) { _, newValue in
						if newValue {
							// In order to remove the focused value too, when I press the plus button
							focusedCurrencyId = nil
							Task {
								// To have a delay and make the change without the user noticing
								try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
								// Empty all the values from the TextFields
								amounts = [:]
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
		} detail: {
			Text("Select an item")
		}
		.onAppear {
			Task {
				lastUpdate = await currencyService.getLastUpdate()
			}
		}
		.onChange(of: scenePhase, { _, newValue in
			if newValue != .active {
				focusedCurrencyId = nil
			}
		})
	}

	private func moveItems(from source: IndexSet, to destination: Int) {
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
