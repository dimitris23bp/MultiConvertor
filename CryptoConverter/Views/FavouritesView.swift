import SwiftUI
import SwiftData

struct FavouritesView: View {
    enum CurrencyType { case fiat, crypto }

    var favouriteCryptos: [Cryptocurrency]
    var favouriteFiats: [FiatCurrency]
    var displayMode: DisplayMode
    @Binding var editMode: EditMode
    @Binding var selection: Set<String>
    @Binding var amounts: [String: Double]
    var focusedCurrencyId: FocusState<String?>.Binding
    let imageSize: CGFloat
    let numberFormatter: NumberFormatter
    
    var onDelete: (any Currency) -> Void
    var onMoveMerged: (IndexSet, Int) -> Void
    var onMoveSeparated: (IndexSet, Int, CurrencyType) -> Void
    var updateInputs: (String, Double) -> Void

    private var combinedFavourites: [any Currency] {
        let all = (favouriteCryptos as [any Currency]) + (favouriteFiats as [any Currency])
        return all.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
    }

    var body: some View {
        List {
            if displayMode == .merged {
                Section {
                    ForEach(combinedFavourites, id: \.id) { currency in
                        currencyRow(for: currency)
                    }
                    .onMove(perform: onMoveMerged)
                }
            } else {
                Section(header: Text("Fiat Currencies")) {
                    ForEach(favouriteFiats, id: \.id) { currency in
                        currencyRow(for: currency)
                    }
                    .onMove(perform: { source, destination in
                        onMoveSeparated(source, destination, .fiat)
                    })
                }
                Section(header: Text("Crypto Currencies")) {
                    ForEach(favouriteCryptos, id: \.id) { currency in
                        currencyRow(for: currency)
                    }
                    .onMove(perform: { source, destination in
                        onMoveSeparated(source, destination, .crypto)
                    })
                }
            }
        }
    }
    
    @ViewBuilder
    private func currencyRow(for currency: any Currency) -> some View {
        HStack {
            if editMode.isEditing {
                Button(action: {
                    if selection.contains(currency.id) {
                        selection.remove(currency.id)
                    } else {
                        selection.insert(currency.id)
                    }
                }) {
                    Image(systemName: selection.contains(currency.id) ? "checkmark.square.fill" : "square")
                }
            }

            Image(uiImage: currency.icon ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)

            VStack(alignment: .leading) {
                Text("\(currency.id)")
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
                Text("\(currency.name)")
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
            }
            .padding()

            Spacer()

            ScrollView(.horizontal, showsIndicators: false) {
                DoubleNumberTextField(
                    value: Binding(
                        get: { amounts[currency.id] ?? 0.0 },
                        set: { newValue in
                            amounts[currency.id] = newValue
                            updateInputs(currency.id, newValue)
                        }
                    ),
                    formatter: numberFormatter
                )
                .focused(focusedCurrencyId, equals: currency.id)
                .id(currency.id)
                .frame(height: 40)
                .fixedSize(horizontal: true, vertical: false)
            }
            .frame(maxWidth: 150)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(focusedCurrencyId.wrappedValue == currency.id ? Color.secondary.opacity(0.2) : Color.clear)
            )
            .animation(.easeOut(duration: 0.1), value: focusedCurrencyId.wrappedValue == currency.id)
            .tint(Color.clear)
            .minimumScaleFactor(0.75)
        }
        .id(currency.id)
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            if editMode.isEditing {
                if selection.contains(currency.id) {
                    selection.remove(currency.id)
                } else {
                    selection.insert(currency.id)
                }
            } else {
                focusedCurrencyId.wrappedValue = currency.id
            }
        })
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: {
                onDelete(currency)
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
