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

	// TODO: Sort based on the sortOrder, and also add functionality to edit order on the edit mode.
	@Query(sort: \CryptoCurrency.sortOrder, animation: .default) private var cryptocurrencies: [CryptoCurrency]

	@Query(
		filter: #Predicate<CryptoCurrency> { $0.favourite },
		sort: \.id,
		animation: .default
	) private var favouriteCryptos: [CryptoCurrency]

	// Repository that encapsulates API + SwiftData mutations
	@State private var repository: CryptoRepository?
	@StateObject private var scheduler = TickerUpdateScheduler()

	@State private var amounts: [String: Double] = [:]
	@State private var editMode: EditMode = .inactive
	@State private var selection = Set<CryptoCurrency.ID>()
	@State private var isShowingSheet = false
	@FocusState private var focusedCryptoId: String?

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
									if editMode.isEditing {
										Button(action: {
											if selection.contains(cryptocurrency.id) {
												selection.remove(cryptocurrency.id)
											} else {
												selection.insert(cryptocurrency.id)
											}
										}) {
											Image(systemName: selection.contains(cryptocurrency.id) ? "checkmark.square.fill" : "square")
										}
									}
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

									DoubleNumberTextField(
										value: Binding(
											get: { amounts[cryptocurrency.id] ?? 0.0 },
											set: { newValue in
												amounts[cryptocurrency.id] = newValue
												updateInputs(basedOn: cryptocurrency.id, with: newValue)
											}
										),
										formatter: numberFormatter
									)
									.focused($focusedCryptoId, equals: cryptocurrency.id)
									.frame(height: 40)
								}
								.swipeActions(edge: .trailing) {
									Button(role: .destructive) {
										cryptocurrency.favourite = false
									} label: {
										Label("Delete", systemImage: "trash")
									}
								}
							}
						} footer: {
							Text("Last updated: \(scheduler.formattedLastExecutionTime)")
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
									Task {
										try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
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

	private func updateInputs(basedOn cryptoId: String, with value: Double) {
		guard let crypto = cryptocurrencies.first(where: { $0.id == cryptoId }) else { return }
		for cryptocurrency in cryptocurrencies where cryptocurrency.favourite {
			let valueDouble = (crypto.value * value) / cryptocurrency.value
			amounts[cryptocurrency.id] = valueDouble
		}
	}

	private func deleteSelectedItems() {
		withAnimation {
			for id in selection {
				if let crypto = favouriteCryptos.first(where: { $0.id == id }) {
					crypto.favourite = false
				}
			}
			selection.removeAll()
			editMode = .inactive
		}
	}
}

#Preview {
	ContentView()
		.modelContainer(Previews.preview)
}
