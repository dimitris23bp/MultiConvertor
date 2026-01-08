import SwiftUI

struct SettingsView: View {
    @State private var showingPrivacyPolicy = false

    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    showingPrivacyPolicy = true
                }) {
                    Text("Privacy Policy")
                        .foregroundStyle(Color.primary)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var policyContent: String = "Loading..."

    var body: some View {
        NavigationStack {
            // Pass the loaded content to our custom renderer
            MarkdownView(content: policyContent)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    loadPolicy()
                }
        }
    }
    
    private func loadPolicy() {
        if let url = Bundle.main.url(forResource: "Privacy_Policy", withExtension: "md") {
            do {
                policyContent = try String(contentsOf: url)
            } catch {
                policyContent = "Error loading Privacy Policy: \(error.localizedDescription)"
            }
        } else {
            policyContent = "Privacy Policy file not found in Bundle."
        }
    }
}

struct MarkdownView: View {
    let content: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Split by newline and enumerate to ensure unique IDs for ForEach
                ForEach(Array(content.components(separatedBy: .newlines).enumerated()), id: \.offset) { index, line in
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
                        if let attributed = try? AttributedString(markdown: trimmed) {
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
    }
}

#Preview {
    SettingsView()
}
