import SwiftUI
import SwiftData

struct AddListItems: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CryptoCurrency.id, animation: .default) private var cryptocurrencies: [CryptoCurrency]
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(cryptocurrencies) { crypto in
                        Text(crypto.name)
                    }
                }
            }
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
    AddListItems()
        .modelContainer(Previews.preview)
}
