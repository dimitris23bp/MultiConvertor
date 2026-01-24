# Favourites Logging Implementation

## Overview
This document explains the logging implementation for favourite currencies in the CryptoConverter app.

## What Was Implemented

### 1. Logging Function
Added a `logFavouritesChange()` function in `FavouritesListView.swift` that:
- Logs all favourite cryptocurrencies with their IDs and names
- Logs all favourite fiat currencies with their IDs and names  
- Logs the combined favourites list with sorting information

### 2. Change Detection
Added `onChange` modifiers to detect when either:
- `favouriteCryptos` array changes
- `favouriteFiats` array changes

### 3. Logging Format
The logs follow this format:
```
[UI] Favourite cryptos changed: 2 items - BTC:Bitcoin, ETH:Ethereum
[UI] Favourite fiats changed: 1 items - USD:US Dollar
[UI] Combined favourites: 3 items - USD:US Dollar, BTC:Bitcoin, ETH:Ethereum
```

## How It Works

1. **When a user adds/removes a favourite**: The SwiftData `@Query` automatically updates
2. **Change detection**: The `onChange` modifier detects the array change
3. **Logging**: The `logFavouritesChange()` function formats and logs the current state
4. **Output**: Logs appear in Xcode console and can be viewed in Console.app

## Benefits

### Debugging
- Track when favourites change and what triggered the change
- See the exact state of favourites at any point in time
- Debug sorting and ordering issues

### Performance Monitoring
- Monitor how often favourites change
- Track the number of favourite items over time
- Identify potential performance bottlenecks

### User Behavior Analysis
- Understand which currencies users favourite most
- Analyze patterns in favourite management
- Track usage of the favourites feature

## Example Scenarios

### Scenario 1: User adds a cryptocurrency to favourites
```
// Before
[UI] Favourite cryptos changed: 1 items - BTC:Bitcoin
[UI] Favourite fiats changed: 1 items - USD:US Dollar
[UI] Combined favourites: 2 items - USD:US Dollar, BTC:Bitcoin

// User taps favourite on ETH
[UI] Favourite cryptos changed: 2 items - BTC:Bitcoin, ETH:Ethereum
[UI] Favourite fiats changed: 1 items - USD:US Dollar
[UI] Combined favourites: 3 items - USD:US Dollar, BTC:Bitcoin, ETH:Ethereum
```

### Scenario 2: User reorders favourites
```
// Before reordering
[UI] Combined favourites: 3 items - USD:US Dollar, BTC:Bitcoin, ETH:Ethereum

// After dragging ETH to top position
[UI] Combined favourites: 3 items - ETH:Ethereum, USD:US Dollar, BTC:Bitcoin
```

### Scenario 3: User removes a favourite
```
// Before
[UI] Favourite cryptos changed: 2 items - BTC:Bitcoin, ETH:Ethereum

// User removes ETH from favourites
[UI] Favourite cryptos changed: 1 items - BTC:Bitcoin
```

## Technical Details

### Logging Infrastructure
- Uses Apple's `OSLog` framework for efficient logging
- Logs are categorized under `Log.ui` for user interface events
- Logs are automatically timestamped and include metadata

### Performance Impact
- Minimal performance impact - logging only occurs when favourites actually change
- Uses efficient string formatting with `map` and `joined`
- No blocking operations or heavy computations

### Thread Safety
- All logging occurs on the main thread (as required by SwiftUI)
- Uses SwiftData's automatic thread management for queries

## Viewing Logs

### In Xcode
1. Run the app in Xcode
2. Open the Debug Area (⌘+⇧+Y)
3. Filter for "[UI]" to see favourites logging

### In Console.app
1. Open Console.app
2. Filter for "CryptoConverter"
3. Look for entries with category "UI"

## Future Enhancements

### Potential Improvements
1. **Log additional details**: Include currency values, market caps, or other metadata
2. **Performance metrics**: Add timing information for large favourite lists
3. **User analytics**: Track which currencies are favourited most often
4. **Error logging**: Add logging for failed favourite operations

### Integration with Analytics
The current logging could be extended to send analytics events:
```swift
Analytics.logEvent("favourites_changed", parameters: [
    "crypto_count": favouriteCryptos.count,
    "fiat_count": favouriteFiats.count,
    "total_count": combinedFavourites.count
])
```

## Troubleshooting

### Logs not appearing?
- Check that the app is running in Debug mode
- Verify that favourites are actually changing (check the UI)
- Ensure the logging level is set to include Info level logs

### Performance issues?
- The logging should have minimal impact, but if needed:
- Add a throttle mechanism to limit logging frequency
- Move logging to a background queue for very large favourite lists

## Conclusion

The favourites logging implementation provides valuable insights into user behavior and helps debug the favourites feature while maintaining excellent performance and following SwiftUI best practices.