//
//  ContentView.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftUI
import SwiftData

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

	@State private var inputTexts: [String: Double] = [:]
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
										let value = inputTexts[cryptocurrency.id] ?? 0
										return value == 0 ? "" : String(format: "%.10f", value)
									},
									set: { input in
										inputTexts[cryptocurrency.id] = Double(input) ?? 0
										updateInputs(basedOn: cryptocurrency.id, with: inputTexts[cryptocurrency.id] ?? 0)
									}
								))
								.multilineTextAlignment(.trailing) // aligns text inside TextField to right
								.keyboardType(.decimalPad)
								.autocorrectionDisabled()
								.font(.title)
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
				if scheduler.checkIfNeeded() {
					scheduler.updateLastExecution()
					try? await repository?.updateTickerValues()
				} else if cryptocurrencies.count < 3 {
					scheduler.updateLastExecution()
					try? await repository?.ensureInitialDataIfNeeded()
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

	private func updateInputs(basedOn cryptoId: String, with value: Double) {
		guard let crypto = cryptocurrencies.first(where: { $0.id == cryptoId }) else { return }
		for cryptocurrency in cryptocurrencies where cryptocurrency.favourite {
			inputTexts[cryptocurrency.id] = (crypto.value * value) / cryptocurrency.value
		}
	}
}

#Preview {
    ContentView()
		.modelContainer(Previews.preview)
}
