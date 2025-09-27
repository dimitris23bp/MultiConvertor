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

	@State private var cryptoPlaceholders = [placeholder(), placeholder2()]
	@State private var inputTexts: [String: String] = [:]
	let imageSize: CGFloat = 48

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(cryptoPlaceholders) { cryptocurrency in
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
					Button("Add") {
						Task {
							fetchLogoURL(for: "BTC")
						}
					}
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

//	private func fetchCryptos() {
//		
//
//	}

	private func fetchLogoURL(for currencyCode: String) {
		Task {
			let url = try! await imageService.fetchLogoURL(for: currencyCode)
			print(url)
		}
	}

}

#Preview {
    ContentView()
		.modelContainer(Previews.preview)
}

