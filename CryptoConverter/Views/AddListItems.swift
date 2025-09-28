import SwiftUI
import SwiftData

struct AddListItems: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CryptoCurrency.id, animation: .default) private var cryptocurrencies: [CryptoCurrency]

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
									.resizable()
									.scaledToFit()
									.frame(width: imageSize, height: imageSize)
							} else {
								AsyncImage(url: URL(string:"https://s2.coinmarketcap.com/static/img/coins/64x64/1.png")) { image in
									image.image?
										.resizable()
										.scaledToFit()
										.frame(width: imageSize, height: imageSize)
								}

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
								crypto.favourite.toggle()
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
    }
}

#Preview {
    AddListItems(imageSize: 48)
        .modelContainer(Previews.preview)
}
