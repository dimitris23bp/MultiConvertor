import Foundation
import FoundationModels
import SwiftUI

// The @main attribute has been removed to resolve the compiler conflict.
@available(macOS 15.0, *)
struct StoryGenerator {

    static func main() async {
		let inputKeywords = ["vækkeur", "underholdende", "vedligeholde"]

        do {
            // Note: The following line will likely cause a "Cannot find 'SystemLanguageModel' in scope" error
            // if 'FoundationModels' does not contain this type.
            guard SystemLanguageModel.default.isAvailable else {
                print("The model is not available on this device.")
                return
            }

            let keywordList = inputKeywords.joined(separator: ", ")
			let prompt = """
				Skriv en kort, engagerende fantasy-historie (under 100 ord), der 
				sømløst inkorporerer alle følgende søgeord: \(keywordList). 
				Tonen skal være mystisk og uhyggelig. Historien skal være på dansk.
				"""
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)

            print("--- Input Keywords ---")
            print(keywordList)
            print("\n--- Generated Story ---")
            print(response.content)

        } catch {
            print("Error generating story: \(error.localizedDescription)")
        }
    }
}

// This block replaces the @main functionality for a script context.
if #available(macOS 15.0, *) {
    Task {
        await StoryGenerator.main()
        // Exit the script once the async task is done.
        exit(0)
    }
    // Keeps the script alive while the async Task runs.
    dispatchMain()
} else {
    print("This script requires macOS 15.0 or later to run.")
}
