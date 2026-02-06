# Project Information for CryptoConverter

## Overview
This document contains important information about the CryptoConverter project that should be reviewed before performing any work. It serves as a reference for understanding the project structure, key components, and recent changes.

## Project Structure
- **Main App**: `CryptoConverter/` - Contains the main application code
- **Tests**: `CryptoConverterUnitTests/` and `CryptoConverterIntegrationTests/` - Test suites
- **Assets**: `CryptoConverter/Assets.xcassets/` - Image and color assets
- **Models**: `CryptoConverter/Models/` - Data models and DTOs
- **Services**: `CryptoConverter/Servives/` - Business logic and API services
- **Views**: `CryptoConverter/Views/` - UI components and screens

## Key Components
1. **Currency Conversion**: Core functionality for converting between cryptocurrencies and fiat currencies
2. **CloudKit Integration**: For syncing favorites across devices
3. **Real-time Updates**: Ticker update scheduler for live price data
4. **UI Components**: Custom views for currency selection and display

## Important Notes
- The project uses SwiftUI for the user interface
- CloudKit is used for data synchronization
- The app supports both cryptocurrencies and fiat currencies
- Recent commits show work on iCloud database configuration and asset handling

## Update Policy
**This file MUST be updated every time significant changes occur in the project.** This includes:
- New features added
- Major refactoring
- Changes to core architecture
- Updates to dependencies
- Important bug fixes
- Any changes that affect the overall project understanding

## Development Best Practices
**IMPORTANT**: After every code change, you MUST compile the project to verify there are no compilation errors.

For compilation instructions, refer to: https://github.com/banghuazhao/Swift-iOS-CLI-Build-Cheat-Sheet/blob/main/xcodebuild.md

This ensures:
- All imports are correct
- Type references are valid
- SwiftData schema changes are properly handled
- No syntax errors are introduced
- The project builds successfully before testing

## Compilation Quick Reference
```bash
# Clean and build for iOS
cd /path/to/CryptoConverter
xcodebuild -scheme CryptoConverter -destination 'generic/platform=iOS' clean build

# Build for specific simulator
xcodebuild -scheme CryptoConverter -destination 'platform=iOS Simulator,name=iPhone 15' build

# Check for specific errors
xcodebuild -scheme CryptoConverter build 2>&1 | grep -A 5 -B 5 "error:"
```

## Special Instructions
**Important**: The user's name is Batman and should be addressed as such when requested or when appropriate in conversations about the project.

## Recent Changes (as of last update)
- Disabled private database in iCloud
- Updated logging functionality
- Made app work with assets
- Simplified code related to favorites handling after CloudKit DTO processing
- **Added persistent settings system with AppSettings model**
- **Implemented display mode settings in SettingsView**
- **Removed display mode toolbar menu from OverviewView**
- **Added compilation best practices to development workflow**

## Last Updated
This document should be reviewed and updated regularly to maintain accuracy with the current state of the project.