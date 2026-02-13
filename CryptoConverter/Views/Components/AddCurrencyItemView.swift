import SwiftUI
import SwiftData

struct AddCurrencyItemView<T>: View where T: Currency, T: PersistentModel {

	var currency: T
    var buttonPressed: (T) -> Void
        
    var body: some View {
		HStack {
			Image(uiImage: currency.icon ?? UIImage())
				.interpolation(.none)
				.resizable()
				.scaledToFit()
				.frame(width: imageSize, height: imageSize)

			VStack(alignment: .leading) {
				Text(String(currency.id))
					.lineLimit(1)
					.font(.body)
					.fontWeight(.regular)

				Text(String(currency.name))
					.font(.body)
					.fontWeight(.regular)
					.minimumScaleFactor(0.75)
					.lineLimit(1)
			}
			.padding()

			Spacer()

			Button {
				buttonPressed(currency)
			} label: {
				Image(systemName: currency.favourite ? "star.fill" : "star")
						.foregroundColor(currency.favourite ? .accentColor : .gray)
						.symbolEffect(.bounce, value: currency.favourite)
			}
			.padding()
		}
		.listRowSeparator(.hidden)
		.listRowBackground(Color("MainColor"))
    }
}

#Preview {
    let currency = Previews.previewBtc

    AddCurrencyItemView(
		currency: currency,
        buttonPressed: { _ in }
    )
}
