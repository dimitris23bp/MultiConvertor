import SwiftUI
import SwiftData
import SVGView

struct AddListItems: View {
    @Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	@Query(sort: \Cryptocurrency.marketCap, order: .reverse, animation: .default) private var cryptocurrencies: [Cryptocurrency]

    @Query(sort: \FiatCurrency.popularity, order: .forward, animation: .default) private var fiatCurrencies: [FiatCurrency]
    
    private var allCurrencies: [any Currency] {
        let all = (cryptocurrencies as [any Currency]) + (fiatCurrencies as [any Currency])
        return all.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
    }

	@State private var searchText: String = ""
	@State private var selectedTab: CurrencyTab = .crypto
	
	let imageSize: CGFloat

	private var dynamicPredicateForCrypto: Predicate<Cryptocurrency> {
		#Predicate<Cryptocurrency> { crypto in
			if !searchText.isEmpty {
				crypto.id.localizedStandardContains(searchText) || crypto.name.localizedStandardContains(searchText)
			} else {
				true
			}
		}
	}

    private var dynamicPredicateForFiat: Predicate<FiatCurrency> {
        #Predicate<FiatCurrency> { fiat in
            if !searchText.isEmpty {
                fiat.id.localizedStandardContains(searchText) || fiat.name.localizedStandardContains(searchText)
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
                        // TODO: This is duplicated. Fix it
						ForEach((try! cryptocurrencies.filter(dynamicPredicateForCrypto))) { crypto in
							HStack {
								
								Image(uiImage: crypto.icon ?? UIImage())
									.interpolation(.none)
									.resizable()
									.scaledToFit()
									.frame(width: imageSize, height: imageSize)
//                                if let icon = crypto.icon {
//                                    AnyView(icon)
//                                        .aspectRatio(contentMode: .fit) // Equivalent to .scaledToFit()
//                                        .frame(width: imageSize, height: imageSize)
//                                }

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
                        ForEach((try! fiatCurrencies.filter(dynamicPredicateForFiat))) { fiat in
							HStack {
                                Image(uiImage: fiat.icon ?? UIImage())
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: imageSize, height: imageSize)
                                
//                                if let icon = fiat.icon {
//                                    AnyView(icon)
//                                        .aspectRatio(contentMode: .fit) // Equivalent to .scaledToFit()
//                                        .frame(width: imageSize, height: imageSize)
//                                }
                                
                                VStack(alignment: .leading) {
                                    Text(String(fiat.id))
                                        .lineLimit(1)
                                        .font(.body)
                                        .fontWeight(.regular)
                                    
                                    Text(String(fiat.name))
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .minimumScaleFactor(0.75)
                                        .lineLimit(1)
                                }
                                .padding()
                                
                                Spacer()
                                
                                Button {
                                    buttonPressed(with: fiat)
                                } label: {
                                    if !fiat.favourite {
                                        Image(systemName: "plus")
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                    }
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
    }
    
//    private func buttonPressed(forType type: CurrencyTab, with item: Currency) {
//        switch type {
//        case CurrencyTab.crypto:
//            buttonPressed(with: item as! Cryptocurrency)
//        case CurrencyTab.fiat:
//            buttonPressed(with: item as! FiatCurrency)
//        }
//    }

    private func buttonPressed(with fiat: FiatCurrency) {
        if fiat.favourite == false {
            let highestOrder = allCurrencies.getHighestOrder()
            fiat.sortOrder = highestOrder + 1
            fiat.favourite = true
        } else {
            fiat.sortOrder = nil
            fiat.favourite = false
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context after reorder: \(error)")
        }
    }
	private func buttonPressed(with crypto: Cryptocurrency) {
		if crypto.favourite == false {
            let highestOrder = allCurrencies.getHighestOrder()
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

#Preview {
    AddListItems(imageSize: 48)
        .modelContainer(Previews.preview)
}
