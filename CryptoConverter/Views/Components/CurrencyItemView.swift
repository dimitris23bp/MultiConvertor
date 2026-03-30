import SwiftUI

struct CurrencyItemView: View {

	var currency: Currency
	@Binding var editMode: EditMode
	@Binding var selection: Set<String>
	@Binding var amount: Double
	var updateInputs: (String, Double) -> Void
	var decimals: Int

	private var numberFormatter: NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = Locale.current
		formatter.maximumFractionDigits = decimals
		return formatter
	}

	var isFocused: Bool

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
					Image(
						systemName: selection.contains(currency.id)
							? "checkmark.circle.fill" : "circle"
					)
				}
			}

			Image(uiImage: currency.icon ?? UIImage())
				.resizable()
				.scaledToFit()
				.frame(width: imageSize, height: imageSize)
				.animation(nil, value: UUID())

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

			if !editMode.isEditing {
				ScrollView(.horizontal, showsIndicators: false) {
					DoubleNumberTextField(
						value: $amount,
						formatter: numberFormatter
					)
					.id(currency.id)
					.frame(height: 40)
					.fixedSize(horizontal: true, vertical: false)
				}
				.frame(maxWidth: 150)
				.fixedSize(horizontal: true, vertical: false)
				.padding(.horizontal, 10)
				.background(
					RoundedRectangle(cornerRadius: 6)
						.fill(
							isFocused
								? Color.secondary.opacity(0.2) : Color.clear
						)
				)
				.animation(
					.easeOut(duration: 0.5),
					value: isFocused
				)
				.transition(.opacity.combined(with: .scale))
				.tint(Color.clear)
				.minimumScaleFactor(0.75)
			}
		}
		.listRowSeparator(.hidden)
		.listRowBackground(Color("MainColor"))
		.id(currency.id)
		.contentShape(Rectangle())
		.simultaneousGesture(
			TapGesture().onEnded {
				onTap(currency)
			}
		)
		.swipeActions(edge: .trailing) {
			Button(
				role: .destructive,
				action: {
					onDelete(currency)
				}
			) {
				Label("Delete", systemImage: "trash")
			}
		}
	}
}
