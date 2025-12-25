# Project Overview

This is a SwiftUI application that functions as a cryptocurrency converter. It allows users to select their favorite cryptocurrencies, view their current values in USD, and convert between them. 

The application has migrated to using **Apple CloudKit** as its primary data source. It fetches cryptocurrency data (including values and SVG logos) from a public CloudKit database and persists them locally using **SwiftData**.

## Key Technologies

*   **UI:** SwiftUI
*   **Data Persistence:** SwiftData
*   **Networking / Backend:** CloudKit (Public Database)
*   **External Dependencies:** 
    *   `SVGKit` (Used for parsing and rendering SVG strings stored in CloudKit into UIImages).

## Architecture

The application follows a repository-based architecture with background scheduling:

*   **Views:** 
    *   `ContentView`: The main view displaying the list of favorite cryptocurrencies and handling user input.
    *   `AddListItems`: A view for adding new cryptocurrencies to the favorites list.
*   **Repository:** 
    *   `CryptoRepository`: Acts as the single source of truth. It manages the synchronization between the remote CloudKit data and the local SwiftData storage. It handles initial seeding and updating of values.
*   **Services:**
    *   `CryptocurrencyService`: A service layer responsible for interacting with CloudKit (fetching records).
    *   `TickerUpdateScheduler`: A helper class that manages background update intervals (e.g., checking for price updates every 60 seconds).
*   **Models:** 
    *   `Cryptocurrency`: The core data model. It is a SwiftData model (`@Model`) that also includes logic to initialize from a `CKRecord` (CloudKit) and render SVG logos using `SVGKit`.

## Data Flow

1.  **Fetching:** `CryptocurrencyService` fetches `CKRecord` objects from the CloudKit public database.
2.  **Mapping:** Records are mapped to `Cryptocurrency` objects. SVG strings from the records are rendered into PNG data using `SVGKit` upon initialization.
3.  **Storage:** `CryptoRepository` saves these objects into the local SwiftData database.
4.  **Display:** SwiftUI views observe the SwiftData context and update automatically when data changes.
5.  **Updates:** `TickerUpdateScheduler` triggers periodic fetches to keep the prices current.

# Building and Running

To build and run the project:
1.  Open `CryptoConverter.xcodeproj` in Xcode.
2.  Ensure you have the necessary iCloud capabilities / signing setup if you intend to write to CloudKit (though reading public data usually requires less valid entitlements, this app seems to read from a public DB).
3.  Run the "CryptoConverter" scheme on a simulator or physical device.

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
