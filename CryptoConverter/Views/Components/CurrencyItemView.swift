import SwiftUI

struct CurrencyItemView: View {

	var currency: Currency
	@Binding var editMode: EditMode
	@Binding var selection: Set<String>
	@Binding var amount: Double
	var updateInputs: (String, Double) -> Void
	let numberFormatter: NumberFormatter
	var focusedCurrencyId: FocusState<String?>.Binding

	var onTap: (any Currency) -> Void
	var onDelete: (any Currency) -> Void

	var body: some View {
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
					value: $amount,
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
		.listRowBackground(Color("MainColor"))
		.id(currency.id)
		.contentShape(Rectangle())
		.simultaneousGesture(TapGesture().onEnded {
			onTap(currency)
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
