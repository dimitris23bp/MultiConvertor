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

    var body: some View {
        NavigationStack {
            Text("Privacy Policy Content")
                .navigationTitle("Privacy Policy")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    SettingsView()
}
