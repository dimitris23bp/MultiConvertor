import SwiftUI
import SwiftData

struct AddCurrencyItemView<T>: View where T: Currency, T: PersistentModel {
    
    var currencies: [T]
    var dynamicPredicate: Predicate<T>
    var buttonPressed: (T) -> Void
        
    var body: some View {
        ForEach((try! currencies.filter(dynamicPredicate))) { currency in
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
					Image(systemName: currency.favourite ? "star.fill" : "star.slash")
							.foregroundColor(currency.favourite ? .yellow : .gray)
							.symbolEffect(.bounce, value: currency.favourite)
                }
                .padding()
            }
        }
    }
}

#Preview {
    let currencies = [Previews.previewBtc, Previews.previewEth]
    
    AddCurrencyItemView(
        currencies: currencies,
        dynamicPredicate: #Predicate<Cryptocurrency> { _ in true },
        buttonPressed: { _ in }
    )
}
