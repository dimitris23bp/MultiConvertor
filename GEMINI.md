# Project Overview

This is a SwiftUI application that functions as a cryptocurrency converter. It allows users to select their favorite cryptocurrencies, view their current values in USD, and convert between them. The application fetches real-time cryptocurrency data from the Coinlore API and cryptocurrency logos from the `logos.tradeloop.app` API. It uses SwiftData for local data persistence.

## Key Technologies

*   **UI:** SwiftUI
*   **Data Persistence:** SwiftData
*   **Networking:** URLSession
*   **APIs:**
    *   Coinlore API (`https://api.coinlore.net/api/tickers/`) for cryptocurrency data.
    *   `logos.tradeloop.app` API for cryptocurrency logos.

## Architecture

The application follows a simple architecture:

*   **Views:** The UI is built with SwiftUI. `ContentView` is the main view, displaying the list of favorite cryptocurrencies and handling user input.
*   **Repository:** `CryptoRepository` acts as a single source of truth for cryptocurrency data. It encapsulates the logic for fetching data from the network and storing it in the local SwiftData database.
*   **Services:**
    *   `CryptoService` is responsible for fetching cryptocurrency data from the Coinlore API.
    *   `ImageService` is responsible for fetching cryptocurrency logos from the `logos.tradeloop.app` API.
*   **Models:** The `CryptoCurrency` model represents a cryptocurrency and is used for both API responses and SwiftData storage.

# Building and Running

To build and run the project, open `CryptoConverter.xcodeproj` in Xcode and run the "CryptoConverter" scheme on a simulator or a physical device.

# Development Conventions

*   **SwiftUI:** The UI is built declaratively using SwiftUI.
*   **SwiftData:** SwiftData is used for local data persistence.
*   **Concurrency:** The application uses `async/await` for asynchronous operations.
*   **Error Handling:** Errors are handled using Swift's `try/catch` mechanism.
*   **Dependency Management:** The project does not use any external dependency management tools like Swift Package Manager or CocoaPods.
