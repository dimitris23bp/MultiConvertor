# Implementation Plan: Metadata Storage

## Objective
Create a dedicated SwiftData model `AppMetadata` to store non-settings persistent data, like the last update timestamps for fiat and cryptocurrencies, avoiding conflating them with user settings.

## Background & Motivation
Currently, `SettingsView` uses `@State` properties for `cryptoLastUpdate` and `fiatLastUpdate`. This causes "Loading..." to be shown every time the view is loaded until CloudKit returns the last update time. The user rejected `@AppStorage` as it introduces a second persistence strategy, and storing this in the existing `AppSettings` model violates its purpose since this is metadata, not user settings. A new `AppMetadata` SwiftData model will serve this need.

## Scope & Impact
- **CryptoConverter/Models/AppMetadata.swift**: New SwiftData model.
- **CryptoConverter/Services/AppMetadataService.swift**: New service to manage the model.
- **CryptoConverter/Views/Screens/SettingsView.swift**: Use the new service to display and update last sync timestamps.
- **CryptoConverterApp.swift**: Register the new service in the environment and `modelContainer`.

## Implementation Steps

1. **Create AppMetadata Model**
   - File: `CryptoConverter/Models/AppMetadata.swift`
   - Create a `@Model final class AppMetadata` with properties:
     - `var fiatLastUpdate: String?`
     - `var cryptoLastUpdate: String?`
   - Initialize them with `nil` by default.

2. **Create AppMetadataService**
   - File: `CryptoConverter/Services/AppMetadataService.swift`
   - Implement `class AppMetadataService: ObservableObject` similar to `AppSettingsService`.
   - Maintain a `@Published var metadata: AppMetadata`.
   - In `init(modelContext: ModelContext)`, fetch the existing `AppMetadata` or insert a new one if it doesn't exist.
   - Add a `save()` method.
   - Create `MetadataServiceKey` (EnvironmentKey) and extend `EnvironmentValues` to expose `metadataService`.

3. **Update SettingsView**
   - Remove `@State private var cryptoLastUpdate` and `@State private var fiatLastUpdate`.
   - Add `@Environment(\.metadataService) private var metadataService`.
   - Update the UI to read from `metadataService?.metadata.cryptoLastUpdate ?? "Loading..."`.
   - Update the UI to read from `metadataService?.metadata.fiatLastUpdate ?? "Loading..."`.
   - In the `.task` modifier:
     - Read the cached values if they exist and are not stale, or temporarily show "Loading...".
     - Await the fresh values from `currencyService.getLastUpdate`.
     - Assign the fresh values to `metadataService?.metadata.cryptoLastUpdate` and `fiatLastUpdate`, then call `metadataService?.save()`.

4. **Update App Registration**
   - In `CryptoConverterApp.swift`, add `AppMetadata.self` to the `ModelContainer` schema.
   - Instantiate `AppMetadataService(modelContext: sharedModelContainer.mainContext)`.
   - Inject `.environment(\.metadataService, appMetadataService)` into the view hierarchy.

## Verification & Testing
- Build and run the app.
- Open Settings, verify "Loading..." appears briefly, then populates with the dates.
- Leave Settings and return; the previous dates should instantly appear without "Loading...".
- Terminate the app and relaunch. The previously fetched dates should display immediately upon entering Settings.

## Migration & Rollback
- SwiftData migration should be trivial as this is a completely new model class added to the container.
- If issues occur, removing `AppMetadata.self` from the schema and reverting `SettingsView` to using `@State` will roll back the changes.