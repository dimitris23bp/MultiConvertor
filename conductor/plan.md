# Singleton Model Service Refactoring Plan

## Objective
Refactor `AppSettingsService` and `AppMetadataService` to remove duplicated code by introducing a generic `SingletonModelService<T>`. This service will handle fetching, creating defaults, and saving for any SwiftData model that functions as a singleton (i.e., stores app-wide state).

## Key Files & Context
- `CryptoConverter/Services/SingletonModelService.swift`: New file to hold the generic service and EnvironmentKeys.
- `CryptoConverter/Services/AppSettingsService.swift`: To be deleted.
- `CryptoConverter/Services/AppMetadataService.swift`: To be deleted.
- `CryptoConverter/CryptoConverterApp.swift`: Update instantiation of the services.
- `CryptoConverter/Views/Screens/SettingsView.swift`: Update property accessors (`settings` and `metadata` to `model`).

## Implementation Steps

1. **Create Generic Service:**
   - Create `CryptoConverter/Services/SingletonModelService.swift`.
   - Implement `SingletonModelService<T: PersistentModel>: ObservableObject`.
   - Add an initializer that takes a `ModelContext` and a `@autoclosure` factory for the default instance.
   - Include Environment Keys setup for both settings and metadata within this file.

2. **Delete Duplicated Services:**
   - Remove `CryptoConverter/Services/AppSettingsService.swift`.
   - Remove `CryptoConverter/Services/AppMetadataService.swift`.

3. **Update App Entry Point (`CryptoConverterApp.swift`):**
   - Change types of `settingsService` and `metadataService` to `SingletonModelService<AppSettings>` and `SingletonModelService<AppMetadata>`.
   - Update their initialization to pass the `ModelContext` and default model instances (`AppSettings()` and `AppMetadata()`).

4. **Update Views (`SettingsView.swift`):**
   - Find references to `settingsService?.settings` and replace them with `settingsService?.model`.
   - Find references to `metadataService?.metadata` and replace them with `metadataService?.model`.

## Verification & Testing
1. **Compilation Check:** Ensure the project compiles without errors.
2. **Runtime Check:** Run the app and open the Settings view. Change a setting (like decimals or display mode) and verify it persists across app restarts. Verify the metadata timestamps are still displaying correctly.
