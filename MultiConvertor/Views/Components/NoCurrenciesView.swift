import SwiftUI

struct NoCurrenciesView: View {
	var body: some View {
		VStack(spacing: 20) {
			// Main icon - using SF Symbol for empty state
			Image(systemName: "star.fill")
				.resizable()
				.scaledToFit()
				.frame(width: 60, height: 60)
				.foregroundColor(.accent)
				.padding()

			// Title
			Text("No Favorite Currencies")
				.font(.title2)
				.fontWeight(.semibold)
				.multilineTextAlignment(.center)

			// Subtitle with instructions
			Text("Tap the + button above to add your first currencies")
				.font(.subheadline)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 30)

		}
		.padding(.vertical, 40)
		.frame(maxWidth: .infinity)
		.listRowBackground(Color("MainColor"))
		.listRowSeparator(.hidden)
	}
}

#Preview {
	NoCurrenciesView()
		.background(Color("MainColor"))
}
