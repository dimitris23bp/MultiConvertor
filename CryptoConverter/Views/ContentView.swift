//
//  ContentView.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftUI
import SwiftData

struct InputValues {
	// Store the trimmed value 1.23456789 will be "1.234567"
	var amountString: String
	// Stores the real value, to be precise in calculations
	var amountDouble: Double
}

struct ContentView: View {
	@Environment(\.scenePhase) private var scenePhase
	@Environment(\.modelContext) private var modelContext
    
    let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

	// TODO: Sort based on the sortOrder, and also add functionality to edit order on the edit mode.
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
    
	// Repository that encapsulates API + SwiftData mutations
	@State private var cryptoRepo: CryptoRepository?
    @State private var cryptoService: CryptocurrencyService?
    // TODO: Fill these files and then use them
    @State private var fiatRepo: FiatRepository?
    @State private var fiatService: FiatCurrencyService?
    
    @State private var allRepo: AllRepository?
    
	@StateObject private var scheduler = TickerUpdateScheduler()

	@State private var amounts: [String: Double] = [:]
	@State private var editMode: EditMode = .inactive
	@State private var selection = Set<Cryptocurrency.ID>()
	@State private var isShowingSheet = false
    @State private var lastUpdate: String = "NaN"
	@FocusState private var focusedCurrencyId: String?

	let imageSize: CGFloat = 42
	
	private var numberFormatter: NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = Locale.current
		formatter.maximumFractionDigits = 8
		return formatter
	}

	var body: some View {
		Group {
			if cryptocurrencies.count < 3 {
				ContentUnavailableView {
					VStack(spacing: 8) {
						// TODO: Change this with a gif or something else that is not just Bitcoin
						Image("btc")
							.resizable()
							.scaledToFit()
							.frame(width: 96, height: 96)
						Text("Wait for data to be fetched.")

						ProgressView()
							.progressViewStyle(CircularProgressViewStyle())
					}
				}
			} else {
				NavigationSplitView {
					List {
						Section {
							ForEach(combinedFavourites, id: \.id) { currency in
                                CurrencyRowView(
                                    currency: currency,
                                    isEditing: editMode.isEditing,
                                    isSelected: selection.contains(currency.id),
                                    amount: amounts[currency.id] ?? 0.0,
                                    imageSize: imageSize,
                                    numberFormatter: numberFormatter,
                                    focusedCurrencyId: $focusedCurrencyId,
                                    onToggleSelection: {
                                        if selection.contains(currency.id) {
                                            selection.remove(currency.id)
                                        } else {
                                            selection.insert(currency.id)
                                        }
                                    },
                                    onAmountChange: { newValue in
                                        amounts[currency.id] = newValue
                                        updateInputs(basedOn: currency.id, with: newValue)
                                    },
                                    onDelete: {
                                        currency.favourite = false
                                    }
                                )
							}
							.onMove(perform: moveItems)
						} footer: {
                            Text("Last updated: \(lastUpdate)")
						}
					}
					.scrollDismissesKeyboard(.interactively)
					.toolbar {
						ToolbarItem(placement: .navigationBarLeading) {
							Button(action: {
								withAnimation {
									editMode = editMode.isEditing ? .inactive : .active
								}
							}) {
								Image(systemName: editMode.isEditing ? "pencil.slash" : "pencil")
							}
						}
						ToolbarItem(placement: .navigationBarTrailing) {
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
					}
					.toolbar {
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
				} detail: {
					Text("Select an item")
				}
			}
		}
		.onAppear {
			Task {
                initializeReposAndServices()
                
				print("Task is called.")
				print("Cryptos saved so far: \(cryptocurrencies.count)")
                
                // TODO: I need to make sure that service is not nullable
                lastUpdate = await cryptoService!.getLastUpdate()
                
				// Check immediately on appear
				if cryptocurrencies.count < 3 || isPreview {
					scheduler.updateLastExecution()
                    // TODO: Do an initial load for some cryptos, and then load the rest in the background. Also add a progress bar on the bottom while this is happening as a v2
					try? await cryptoService?.ensureInitialDataIfNeeded()
                    try? await fiatService?.ensureInitialDataIfNeeded()
                    try? await allRepo?.addInitialFavourites(currencies: allCurrencies)

					print("Initial data has happened")
				} else if scheduler.checkIfNeeded() {
					scheduler.updateLastExecution()
					await cryptoService?.updateAmountOfCryptos()
                    await fiatService?.updateAmountOfFiats()
					print("Update has happened")
				}
				scheduler.start { [weak cService = cryptoService, weak fService = fiatService] in
					await cService?.updateAmountOfCryptos()
                    await fService?.updateAmountOfFiats()
				}
			}
		}
		.onDisappear {
			scheduler.stop()
		}
		.onChange(of: scenePhase, { _, newValue in
			switch newValue {
			case .active:
				if scheduler.checkIfNeeded() {
					Task {
						scheduler.updateLastExecution()
						await cryptoService?.updateAmountOfCryptos()
                        await fiatService?.updateAmountOfFiats()
					}
				}
			default:
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
			let valueDouble = (source.value * value) / currency.value
			amounts[currency.id] = valueDouble
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
    
    private func initializeReposAndServices() {
        // TODO: Do I need to check them both?
        // TODO: Do I need temp vars?
        if cryptoRepo == nil && fiatRepo == nil {
            let repoCrypto = CryptoRepository(modelContext: modelContext)
            cryptoRepo = repoCrypto
            
            let repoFiat = FiatRepository(modelContext: modelContext)
            fiatRepo = repoFiat
            
            let repoAll = AllRepository(modelContext: modelContext)
            allRepo = repoAll
            
            let cloudKitService = CloudKitService()
            cryptoService = CryptocurrencyService(repository: repoCrypto, cloudKitService: cloudKitService)
            fiatService = FiatCurrencyService(fiatRepository: repoFiat, cloudkitService: cloudKitService)
        }
    }
    
}

struct CurrencyRowView: View {
    let currency: any Currency
    let isEditing: Bool
    let isSelected: Bool
    let amount: Double
    let imageSize: CGFloat
    let numberFormatter: NumberFormatter
    var focusedCurrencyId: FocusState<String?>.Binding
    let onToggleSelection: () -> Void
    let onAmountChange: (Double) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            if isEditing {
                Button(action: onToggleSelection) {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
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
                        get: { amount },
                        set: onAmountChange
                    ),
                    formatter: numberFormatter
                )
                .focused(focusedCurrencyId, equals: currency.id)
                .frame(height: 40)
                .fixedSize(horizontal: true, vertical: false)
            }
            .frame(maxWidth: 150)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(focusedCurrencyId.wrappedValue == currency.id ? Color.secondary.opacity(0.2) : Color.clear)
            )
            .animation(.easeOut(duration: 0.1), value: focusedCurrencyId.wrappedValue == currency.id)
            .tint(Color.clear)
            .minimumScaleFactor(0.75)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}


#Preview {
	ContentView()
		.modelContainer(Previews.preview)
}
