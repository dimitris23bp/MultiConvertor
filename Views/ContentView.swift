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

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(cryptocurrencies) { cryptocurrency in
                    NavigationLink {
						Text("A new currency: \(cryptocurrency.name)")
                    } label: {
						HStack {
							Text("\(cryptocurrency.name)")

							Text("\(cryptocurrency.value)")
						}
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
