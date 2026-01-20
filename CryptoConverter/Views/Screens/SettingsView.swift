import SwiftUI

struct SettingsView: View {
	var body: some View {
		NavigationStack {
			List {
//				Section {
//					NavigationLink(destination: Text("Membership features coming soon!")) {
//						Text("Upgrade to Pro")
//					}
//				} header: {
//					Text("Membership")
//				}

				Section {
					NavigationLink(destination: PrivacyPolicyView()) {
						Text("Privacy Policy")
					}
//					NavigationLink(destination: Text("Support features coming soon!")) {
//						Text("Contact Support")
//					}
				} header: {
					Text("Additional Info")
				}
			}
			.navigationTitle("Settings")
		}
	}
}

struct PrivacyPolicyView: View {
	@State private var policyContent: String = "Loading..."

	var body: some View {
		MarkdownView(content: policyContent)
			.onAppear {
				loadPolicy()
			}
	}
	
	private func loadPolicy() {
		if let url = Bundle.main.url(forResource: "Privacy_Policy", withExtension: "md") {
			do {
				policyContent = try String(contentsOf: url, encoding: .utf8)
			} catch {
				policyContent = "Error loading Privacy Policy: \(error.localizedDescription)"
			}
		} else {
			policyContent = "Privacy Policy file not found in Bundle."
		}
	}
}


#Preview {
	SettingsView()
}
