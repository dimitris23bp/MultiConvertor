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

	@Query(sort: \CryptoCurrency.id, animation: .default) private var cryptocurrencies: [CryptoCurrency]

	@Query(
		filter: #Predicate<CryptoCurrency> { $0.favourite },
		sort: \.id,
		animation: .default
	) private var favouriteCryptos: [CryptoCurrency]

	// Repository that encapsulates API + SwiftData mutations
	@State private var repository: CryptoRepository?
	@StateObject private var scheduler = TickerUpdateScheduler()

	@State private var inputTexts: [String: InputValues] = [:]
	@State private var isShowingSheet = false
	@FocusState private var focusedCryptoId: String?

	let imageSize: CGFloat = 42

    var body: some View {
		Group {
			if cryptocurrencies.filter({ $0.imageData != nil }).count < 50 {
				ContentUnavailableView {
					VStack(spacing: 8) {
						Label("Wait for data to be fetched.", image: .bitcoin)
							.padding()
						ProgressView()
							.progressViewStyle(CircularProgressViewStyle())
					}
				}
			} else {
				NavigationSplitView {
					List {
						Section {
							ForEach(favouriteCryptos) { cryptocurrency in
								HStack {
									if let image = cryptocurrency.image {
										image
											.resizable()
											.scaledToFit()
											.frame(width: imageSize, height: imageSize)
									} else {
										Image(systemName: "questionmark")
											.resizable()
											.scaledToFit()
											.frame(width: imageSize, height: imageSize)
									}

									VStack(alignment: .leading) {
										Text("\(cryptocurrency.id)")
										Text("\(cryptocurrency.name)")
											.minimumScaleFactor(0.75)
											.lineLimit(1)
									}
									.padding()

									Spacer()

									TextField("0", text: Binding(
										get: {
											let value = inputTexts[cryptocurrency.id]?.amountDouble ?? 0
											let displayedValue = displayCorrectValue(value)
											if cryptocurrency.id == "ETH" {
												print("Value of ETH is: \(displayedValue)")
											}
											return displayedValue
										},
										set: { input in
											let previousInput = inputTexts[cryptocurrency.id]?.amountString
											if input == previousInput {
												if cryptocurrency.id == "BTC" {
													print("No need for this")
												}
												return
											}

											let inputValues = inputTexts[cryptocurrency.id] ?? InputValues(amountString: "", amountDouble: 0)
											if inputValues.amountString != input || input == "" {
												// TODO: For me to remember: I switched separetor, now I need to add . or , for the thousands e.g. 1.234.456,56
												updateInputs(basedOn: cryptocurrency.id, with: parseLocaleDouble(from: input) ?? 0)
											}
										}
									))
									.multilineTextAlignment(.trailing) // aligns text inside TextField to right
									.keyboardType(.decimalPad)
									.autocorrectionDisabled()
									.tint(.clear)
									.font(.title)
									.padding(6)
									.background(RoundedRectangle(cornerRadius: 6).fill(Color.gray.opacity(0.15)))
									.focused($focusedCryptoId, equals: cryptocurrency.id)
								}
								.swipeActions(edge: .trailing) {
									Button(cryptocurrency.favourite ? "Remove from favourites" : "Add to favourites", systemImage: "trash") {
										withAnimation {
											cryptocurrency.favourite.toggle()
										}
										do {
											try modelContext.save()
										} catch {
											print(error)
										}
									}
									.tint(.red)
								}
							}
						} footer: {
							Text("Last updated: \(scheduler.formattedLastExecutionTime)")
						}
					}
					.scrollDismissesKeyboard(.interactively)
					.toolbar {
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
									Task {
										try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
										inputTexts = [:]
									}
								}
							}
						}
					}
				} detail: {
					Text("Select an item")
				}
			}
		}
		.onAppear {
			Task {
				if repository == nil {
					repository = CryptoRepository(modelContext: modelContext)
				}
				print("Task is called.")
				print("Cryptos saved so far: \(cryptocurrencies.count)")
				// Check immediately on appear
				if cryptocurrencies.count < 3 {
					scheduler.updateLastExecution()
					try? await repository?.ensureInitialDataIfNeeded()
					print("Initial data has happened")
				} else if scheduler.checkIfNeeded() {
					scheduler.updateLastExecution()
					try? await repository?.updateTickerValues()
					print("Update has happened")
				}
				scheduler.start { [weak repository = repository] in
					try? await repository?.updateTickerValues()
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
						try? await repository?.updateTickerValues()
					}
				}
			default:
				focusedCryptoId = nil
			}
		})
	}

	func parseLocaleDouble(from string: String) -> Double? {
		let formatter = NumberFormatter()
		formatter.locale = Locale.current

		let stringToParse: String
		if formatter.groupingSeparator == "," {
			stringToParse = string.replacingOccurrences(of: ",", with: "")
		} else if formatter.groupingSeparator == "." {
			stringToParse = string.replacingOccurrences(of: ".", with: "")
		} else {
			stringToParse = string
		}

		// Configure formatter for decimal numbers
		formatter.numberStyle = .decimal

		return formatter.number(from: stringToParse)?.doubleValue
	}

	private func displayCorrectValue(_ value: Double) -> String {
	    if value == 0 {
	        return ""
	    }
	    let formatter = NumberFormatter()
	    formatter.locale = Locale.current
	    formatter.numberStyle = .decimal
	    formatter.maximumFractionDigits = 8
	    formatter.minimumFractionDigits = 0
	    formatter.usesGroupingSeparator = true
	    
	    if let formattedString = formatter.string(from: NSNumber(value: value)) {
	        return formattedString
	    } else {
	        return String(value)
	    }
	}

	private func updateInputs(basedOn cryptoId: String, with value: Double) {
		guard let crypto = cryptocurrencies.first(where: { $0.id == cryptoId }) else { return }
		for cryptocurrency in cryptocurrencies where cryptocurrency.favourite {
			let valueDouble = (crypto.value * value) / cryptocurrency.value
			if valueDouble.isZero {
				// Clear input for zero value to match displayCorrectValue logic
				inputTexts[cryptocurrency.id] = InputValues(amountString: "", amountDouble: valueDouble)
			} else {
				// Use displayCorrectValue to format respecting user's locale
				let formattedValueString = displayCorrectValue(valueDouble)
				inputTexts[cryptocurrency.id] = InputValues(amountString: formattedValueString, amountDouble: valueDouble)
			}
		}
	}
}

#Preview {
    ContentView()
		.modelContainer(Previews.preview)
}
