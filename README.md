# MultiConvertor

MultiConvertor is a native iOS application built entirely with SwiftUI that provides seamless, real-time conversion between various cryptocurrencies and fiat currencies. Designed for simplicity and speed, it allows users to monitor their favorite currency pairs and convert values on the fly.

> [!NOTE]
> **MultiConvertor will soon be available on the App Store!**

## High-Level Overview

At its core, MultiConvertor is a data-driven SwiftUI application. It fetches live market data for cryptocurrencies and fiat currencies, processes this data through internal services, and updates the user interface in real-time. 

### Key Features
- **Comprehensive Conversions:** Support for converting between both fiat money and cryptocurrencies.
- **CloudKit Integration:** Reads live market data (prices and icons) for cryptocurrencies and fiat currencies from a public CloudKit database. Additionally, syncs user's favorite currencies across all their Apple devices via iCloud.
- **Real-Time Data:** Utilizes a custom ticker update scheduler to ensure live price data is always accurate.
- **Modern UI:** Custom, sleek views for selecting, displaying, and managing currency lists.

## Architecture

The project follows a modular and clean architecture, separating concerns across distinct components:

- **`Views/`**: Contains the SwiftUI user interface components, screens, and custom visual elements.
- **`Models/`**: Houses the data structures, Data Transfer Objects (DTOs), and domain models.
- **`Services/`**: Manages the core business logic, API networking, and external data fetching.
- **`Repository/`**: Handles the persistence layer, likely interfacing with CloudKit and local storage mechanisms.
- **`TickerUpdateScheduler`**: A background job scheduler responsible for periodically fetching and updating live price data so the user always sees the latest rates.

## How it works

1. **Data Ingestion:** The app reaches out to external APIs via its `Services` to fetch the latest cryptocurrency and fiat exchange rates.
2. **Synchronization:** The `TickerUpdateScheduler` operates on a timer (or on demand) to keep the internal state refreshed.
3. **User Preferences:** User selections, such as their favorite currencies, are persisted locally on-device using SwiftData via the `Repository` layer.
4. **Presentation:** The data is funneled into SwiftUI `Views` which reactively update the UI using Swift's observable patterns whenever new data arrives.

## Testing

The project is equipped with test suites to ensure stability and correctness:
- **`MultiConvertorUnitTests/`**: Dedicated to testing individual services, mappers, and business logic in isolation.
- **`MultiConvertorIntegrationTests/`**: Focuses on the integration of various components and data flow across the app.

## Development & Compilation

The project uses a standard Xcode build system. You can verify compilations via the command line (make sure there are no errors after changes):

```bash
# Clean and build for iOS
xcodebuild -scheme MultiConvertor -destination 'generic/platform=iOS' clean build
```

*(Note: Use `generic/platform=iOS` for verification to avoid simulator timeout issues.)*
