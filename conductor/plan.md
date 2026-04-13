# Move Service Initialization to App Level

## Objective
Move the `CurrencyService` instantiation to the App root (`CryptoConverterApp.swift`) so that the service persists for the entire lifecycle of the application. This ensures there is exactly one instance, eliminating redundant background task instantiations, preventing deadlocks, and keeping the view lightweight. We will inject the service into the SwiftUI hierarchy using **Environment Injection**.

## Key Files & Context
- `CryptoConverter/CryptoConverterApp.swift`
- `CryptoConverter/Views/Screens/MainTabView.swift`
- `CryptoConverter/Views/Screens/SettingsView.swift`
- `CryptoConverter/Preview/Previews.swift`

## Implementation Steps

1. **Update `Previews.swift`:**
   Add a helper property `previewCurrencyService: CurrencyService` to the `Previews` struct so we can easily inject it into any preview environment without boilerplate.

2. **Define Environment Key:**
   Create an `EnvironmentKey` for `CurrencyService` and an extension on `EnvironmentValues` to allow `@Environment(\.currencyService) var currencyService`. We can place this extension near the `CurrencyService` definition or in a new file, but placing it in `CryptoConverterApp.swift` or `CurrencyService.swift` is fine. We will place it in `CurrencyService.swift`.

3. **Refactor `CryptoConverterApp.swift`:**
   - Define a custom `init()` that handles the creation of the `ModelContainer` and `ModelConfiguration`.
   - Initialize `sharedModelContainer` and a new constant `let currencyService: CurrencyService` inside the `init()`, using the container's `mainContext`.
   - In the `body`, attach `.environment(\.currencyService, currencyService)` to the `WindowGroup`.

4. **Refactor `MainTabView.swift` & `SettingsView.swift`:**
   - Change `MainTabView` to access the service via `@Environment(\.currencyService) var currencyService`.
   - Remove the `stableCurrencyService` state, the `currencyService` computed property, and the `@Environment(\.modelContext)` from `MainTabView`.
   - Change `SettingsView` to also access the service via `@Environment(\.currencyService)` instead of accepting it in its initializer.
   - Update `.task` in `MainTabView` to use the environment `currencyService`.
   - Update `#Preview` in both views to attach `.environment(\.currencyService, Previews.previewCurrencyService)`.

## Verification & Testing
- Build the app using Xcode build command to verify compilation.
- Ensure the previews for `MainTabView` and `SettingsView` still work.
- Verify that data fetching and background updates function as expected without locking or duplicating tasks.