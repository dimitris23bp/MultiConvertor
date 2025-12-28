import SwiftUI
import SwiftData

struct AddListItems: View {
    @Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	@Query(sort: \Cryptocurrency.marketCap, order: .reverse, animation: .default) private var cryptocurrencies: [Cryptocurrency]

	@State private var repository: CryptoRepository?
	@State private var searchText: String = ""
	@State private var selectedTab: CurrencyTab = .crypto
	
	let imageSize: CGFloat

	private var dynamicPredicate: Predicate<Cryptocurrency> {
		#Predicate<Cryptocurrency> { crypto in
			if !searchText.isEmpty {
				crypto.id.localizedStandardContains(searchText) || crypto.name.localizedStandardContains(searchText)
			} else {
				true
			}
		}
	}
	
	// Mock Data for Fiat
	private let fiatCurrencies: [FiatCurrency] = [
		FiatCurrency(code: "USD", name: "United States Dollar", icon: "dollarsign.circle.fill"),
		FiatCurrency(code: "EUR", name: "Euro", icon: "eurosign.circle.fill"),
		FiatCurrency(code: "GBP", name: "British Pound Sterling", icon: "sterlingsign.circle.fill"),
		FiatCurrency(code: "JPY", name: "Japanese Yen", icon: "yensign.circle.fill"),
		FiatCurrency(code: "CNY", name: "Chinese Yuan", icon: "yensign.circle.fill")
	]
	
	private var filteredFiat: [FiatCurrency] {
		if searchText.isEmpty {
			return fiatCurrencies
		} else {
			return fiatCurrencies.filter {
				$0.code.localizedStandardContains(searchText) || $0.name.localizedStandardContains(searchText)
			}
		}
	}

    var body: some View {
        NavigationStack {
            VStack {
                List {
					if selectedTab == .crypto {
						ForEach((try! cryptocurrencies.filter(dynamicPredicate))) { crypto in
							HStack {
								
								Image(uiImage: crypto.logo ?? UIImage())
									.interpolation(.none)
									.resizable()
									.scaledToFit()
									.frame(width: imageSize, height: imageSize)
								
								VStack(alignment: .leading) {
									Text(String(crypto.id))
										.lineLimit(1)
										.font(.body)
										.fontWeight(.regular)
									
									Text(String(crypto.name))
										.font(.body)
										.fontWeight(.regular)
										.minimumScaleFactor(0.75)
										.lineLimit(1)
								}
								.padding()
								
								Spacer()
								
								Button {
									buttonPressed(with: crypto)
								} label: {
									if !crypto.favourite {
										Image(systemName: "plus")
											.font(.title3)
											.foregroundColor(.primary)
									}
								}
								.padding()
							}
						}
					} else {
						ForEach(filteredFiat) { fiat in
							HStack {
								Image(systemName: fiat.icon)
									.resizable()
									.scaledToFit()
									.frame(width: imageSize, height: imageSize)
									.foregroundColor(.gray)

								VStack(alignment: .leading) {
									Text(fiat.code)
										.lineLimit(1)
										.font(.body)
										.fontWeight(.regular)

									Text(fiat.name)
										.font(.body)
										.fontWeight(.regular)
										.minimumScaleFactor(0.75)
										.lineLimit(1)
								}
								.padding()

								Spacer()
								
								// Placeholder button for Fiat
								Button {
									// Action for fiat
								} label: {
									Image(systemName: "plus")
										.font(.title3)
										.foregroundColor(.primary)
								}
								.padding()
							}
						}
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
		.onAppear {
			repository = CryptoRepository(modelContext: modelContext)
		}
    }

	private func buttonPressed(with crypto: Cryptocurrency) {
		if crypto.favourite == false {
			let highestOrder = repository?.getHighestOrder() ?? 0
			crypto.sortOrder = highestOrder + 1
			crypto.favourite = true
		} else {
			crypto.sortOrder = nil
			crypto.favourite = false
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

struct FiatCurrency: Identifiable {
	let id = UUID()
	let code: String
	let name: String
	let icon: String
}


#Preview {
    AddListItems(imageSize: 48)
        .modelContainer(Previews.preview)
}
