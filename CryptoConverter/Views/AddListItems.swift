import SwiftUI
import SwiftData

struct AddListItems: View {
    @Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	@Query(sort: \CryptoCurrency.marketCap, order: .reverse, animation: .default) private var cryptocurrencies: [CryptoCurrency]

	@State private var repository: CryptoRepository?
	@State private var searchText: String = ""
	let imageSize: CGFloat

	private var dynamicPredicate: Predicate<CryptoCurrency> {
		#Predicate<CryptoCurrency> { crypto in
			if !searchText.isEmpty {
				crypto.id.localizedStandardContains(searchText) || crypto.name.localizedStandardContains(searchText)
			} else {
				true
			}
		}
	}
    var body: some View {
        NavigationStack {
            VStack {
                List {
					ForEach((try! cryptocurrencies.filter(dynamicPredicate))) { crypto in
						HStack {
							if crypto.imageData != nil {
								crypto.image!
									.interpolation(.none)
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
								Text("\(crypto.id)")
								Text("\(crypto.name)")
									.minimumScaleFactor(0.75)
									.lineLimit(1)
							}
							.padding()

							Spacer()

							Button {
								if crypto.favourite == false {
									let highestOrder = repository?.getHighestOrder() ?? 0
									crypto.sortOrder = highestOrder + 1
									crypto.favourite = true
								} else {
									crypto.sortOrder = nil
									crypto.favourite = false
								}
							} label: {
								if !crypto.favourite {
									Image(systemName: "plus")
										.font(.title)
								}
							}
							.padding()
						}
                    }
                }
            }
			.searchable(text: $searchText)
			.animation(.default, value: searchText)
            .toolbar {
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
}

#Preview {
    AddListItems(imageSize: 48)
        .modelContainer(Previews.preview)
}
