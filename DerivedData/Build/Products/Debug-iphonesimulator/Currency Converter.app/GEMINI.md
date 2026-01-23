# Project Overview

This is a SwiftUI application that functions as a cryptocurrency and fiat currency converter. It allows users to select their favorite currencies (crypto or fiat), view their current values, and convert between them. 

The application has migrated to using **Apple CloudKit** as its primary data source. It fetches currency data (including values and logos) from a public CloudKit database and persists them locally using **SwiftData**.

## Key Technologies

*   **UI:** SwiftUI
*   **Data Persistence:** SwiftData
*   **Networking / Backend:** CloudKit (Public Database)
*   **External Dependencies:** 
    *   `SVGKit` (Used for parsing and rendering SVG strings stored in CloudKit into UIImages).

## Architecture

The application follows a repository-based architecture with background scheduling and DTO usage for thread safety:

*   **Views:** 
    *   `ContentView`: The main view displaying the list of favorite currencies and handling user input.
    *   `AddListItems`: A view for adding new currencies to the favorites list.
    *   `ListCategory`: A generic view used to display lists of currencies (Crypto or Fiat).
    *   `DoubleNumberTextField`: A custom `UIViewRepresentable` text field handling specific number formatting and focus behaviors.
*   **Repository:** 
    *   `AllRepository`: The main coordinator repository (`@MainActor`). It manages `CryptoRepository` and `FiatRepository` and handles generic actions for types conforming to `CurrencyDTO`.
    *   `CryptoRepository`: Manages synchronization of `Cryptocurrency` data.
    *   `FiatRepository`: Manages synchronization of `FiatCurrency` data.
*   **Services:**
    *   `CryptocurrencyService` & `FiatCurrencyService`: Service layers responsible for interacting with CloudKit to fetch records.
    *   `CloudKitService`: A shared service protocol/implementation for CloudKit operations.
    *   `TickerUpdateScheduler`: Manages background update intervals.
*   **Models:** 
    *   `Currency` (Protocol): Unifies `Cryptocurrency` and `FiatCurrency`.
    *   `Cryptocurrency` & `FiatCurrency`: SwiftData models (`@Model`). They include logic to initialize from DTOs or `CKRecord` and handle image data (external storage).
    *   **DTOs**: `CryptocurrencyDTO`, `FiatCurrencyDTO`. Thread-safe intermediate structs used to transfer data from background services to the main actor repositories.

## Data Flow

1.  **Fetching:** Services (`CryptocurrencyService`, `FiatCurrencyService`) fetch `CKRecord` objects from the CloudKit public database via `CloudKitService`.
2.  **DTO Mapping:** Records are mapped to DTOs (`CryptocurrencyDTO`, `FiatCurrencyDTO`). SVG strings or image data are processed at this stage or upon initialization.
3.  **Transfer:** DTOs are passed to `AllRepository` (or specific repositories).
4.  **Storage:** Repositories map DTOs to SwiftData models (`Cryptocurrency`, `FiatCurrency`) and save them to the local database.
5.  **Display:** SwiftUI views (`ListCategory` inside `ContentView`/`AddListItems`) observe the SwiftData context and update automatically.
6.  **Updates:** `TickerUpdateScheduler` triggers periodic fetches to keep values current.

# Building and Running

To build and run the project:
1.  Open `CryptoConverter.xcodeproj` in Xcode.
2.  Ensure you have the necessary iCloud capabilities / signing setup if you intend to write to CloudKit (though reading public data usually requires less valid entitlements, this app seems to read from a public DB).
3.  Run the "CryptoConverter" scheme on a simulator or physical device.
4.  Use always `-quiet`, so you won't launch an interactive shell.

# Development Conventions

*   **SwiftUI:** The UI is built declaratively using SwiftUI.
*   **SwiftData:** Used for local caching and offline capabilities.
*   **Concurrency:** Heavy use of `async/await` and `@MainActor` to ensure UI safety.
*   **CloudKit:** Data is fetched in batches using cursors to handle large datasets.

# Testing Guidelines

*   **Mocking:** Only use mocking in Unit Tests. Integration tests must use real implementations.
*   **Structure:** Test directories must mirror the project structure.
    *   `CryptoConverter/Repository/CryptoRepository.swift` -> `CryptoConverterUnitTests/Repository/CryptoRepositoryUnitTests.swift`
    *   `CryptoConverter/Repository/CryptoRepository.swift` -> `CryptoConverterIntegrationTests/Repository/CryptoRepositoryIntegrationTests.swift`
*   **Mocks:** Mocks should be placed in a subfolder named `Mock` within the mirrored directory.
    *   Example: `CryptoConverterUnitTests/Servives/Mock/CryptocurrencyServiceMock.swift`
*   **Naming:**
    *   Unit Tests: `[FileName]UnitTests.swift`
    *   Integration Tests: `[FileName]IntegrationTests.swift`
    *   Mocks: `[FileName]Mock.swift`
*   **Libraries:** Use standard, modern libraries (e.g., XCTest, Swift Testing) and dependency injection via protocols.

# Rules to follow

*   Always use tabs instead of spaces.
*   Always follow the instructions that were given and don't change unrelated code.
