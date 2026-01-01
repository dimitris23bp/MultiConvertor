import SwiftUI
import SwiftData

struct ListCategory<T>: View where T: Currency, T: PersistentModel {
    
    var currencies: [T]
    var dynamicPredicate: Predicate<T>
    var imageSize: CGFloat
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
                    if !currency.favourite {
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

#Preview {
    let currencies = [Previews.previewBtc, Previews.previewEth]
    
    ListCategory(
        currencies: currencies,
        dynamicPredicate: #Predicate<Cryptocurrency> { _ in true },
        imageSize: 48,
        buttonPressed: { _ in }
    )
}
