//
//  ContentView.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
	@Query(sort: \CryptoCurrency.id, animation: .default) private var cryptocurrencies: [CryptoCurrency]

	private let imageService = ImageService()
	private let cryptoService = CryptoService()

//	@State private var cryptoPlaceholders = [placeholder(), placeholder2()]
	@State private var inputTexts: [String: String] = [:]
	@State private var hasFetched: Bool = false

	let imageSize: CGFloat = 48
	private var dynamicPredicate: Predicate<CryptoCurrency> {
		#Predicate<CryptoCurrency> { crypto in
			crypto.favourite
		}
	}

    var body: some View {
        NavigationSplitView {
            List {
                ForEach((try! cryptocurrencies.filter(dynamicPredicate))) { cryptocurrency in
					HStack {
						if cryptocurrency.imageData != nil {
							cryptocurrency.image
						} else {
							AsyncImage(url: URL(string:"https://s2.coinmarketcap.com/static/img/coins/64x64/1.png")) { image in
								image.image?
									.resizable()
									.scaledToFit()
									.frame(width: imageSize, height: imageSize)
							}

						}

						VStack(alignment: .leading) {
							Text("\(cryptocurrency.id)")
							Text("\(cryptocurrency.name)")
								.minimumScaleFactor(0.75)
						}
						.padding()

						Spacer()

						TextField("0", text: Binding(
							get: {
								inputTexts[cryptocurrency.id, default: ""]
							},
							set: {
								inputTexts[cryptocurrency.id] = $0
							}
						))
						.multilineTextAlignment(.trailing) // aligns text inside TextField to right
						.keyboardType(.decimalPad)
						.autocorrectionDisabled()

					}
                }
            }
			.task(priority: .userInitiated) {
				print("Task is called")
				print("Cryptos saved so far: \(cryptocurrencies.count)")
				guard !hasFetched else { return }
				hasFetched = true
				await fetchCryptos()
			}
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
					Button("Add") {
					}
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

	private func fetchCryptos() async {
		do {
			let tickers = try await cryptoService.fetchTickers()
			for ticker in tickers {
				if let crypto = CryptoCurrency(ticker: ticker) {
					print("The id of the inserted is: \(crypto.id)")
					if crypto.id == "BTC" || crypto.id == "ETH" {
						crypto.favourite = true
					}
					modelContext.insert(crypto)
					try await Task.sleep(nanoseconds: 1_000_000)
				}
			}
		} catch {
			print(error)
		}
		print("FetchLogoURLs is called")

		fetchLogoURLs()
	}

	private func fetchLogoURLs() {
		Task {
			let idsAndUrls = try! await imageService.fetchLogoURLs(for: cryptocurrencies.map(\.id))
			await fillInDatabase(idsAndUrls)
		}
	}

	private func fillInDatabase(_ idsAndUrls: [String : URL]) async {
		for crypto in cryptocurrencies {
			if let url = idsAndUrls[crypto.id] {
				do {
					crypto.imageData = try await URLSession.shared.data(from: url).0
					print("Got image for \(crypto.id) with URL: \(url)")
					try modelContext.save()
				} catch {
					print(error)
				}
			}
		}

	}

}

#Preview {
    ContentView()
		.modelContainer(Previews.preview)
}

