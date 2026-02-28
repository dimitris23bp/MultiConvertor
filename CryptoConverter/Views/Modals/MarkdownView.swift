import SwiftUI

struct MarkdownView: View {
	@State private var content: String = "Loading..."
	let fileName: String

	var displayName: String {
		return fileName.replacingOccurrences(of: "_", with: " ")
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				// Split by newline and enumerate to ensure unique IDs for ForEach
				ForEach(
					Array(
						content.components(separatedBy: .newlines).enumerated()
					),
					id: \.offset
				) { index, line in
					let trimmed = line.trimmingCharacters(in: .whitespaces)

					if trimmed.hasPrefix("# ") {
						Text(trimmed.dropFirst(2))
							.font(.largeTitle)
							.bold()
					} else if trimmed.hasPrefix("## ") {
						Text(trimmed.dropFirst(3))
							.font(.title)
							.bold()
							.padding(.top, 8)
					} else if trimmed.hasPrefix("### ") {
						Text(trimmed.dropFirst(4))
							.font(.headline)
							.bold()
							.padding(.top, 4)
					} else if trimmed.isEmpty {
						// Spacer for empty lines
						Spacer().frame(height: 4)
					} else {
						// Body text: Attempt to parse inline markdown (bold, italics, links)
						if let attributed = try? AttributedString(
							markdown: trimmed
						) {
							Text(attributed)
								.font(.body)
								.foregroundStyle(.primary)
						} else {
							Text(trimmed)
								.font(.body)
						}
					}
				}
			}
			.padding()
		}
		.onAppear {
			loadFile()
		}
	}

	private func loadFile() {
		if let url = Bundle.main.url(forResource: fileName, withExtension: "md")
		{
			do {
				content = try String(contentsOf: url, encoding: .utf8)
			} catch {
				content =
					"Error loading \(displayName): \(error.localizedDescription)"
			}
		} else {
			content = "\(displayName) file not found in Bundle."
		}
	}

}
