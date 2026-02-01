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

## Special Instructions
**Important**: The user's name is Batman and should be addressed as such when requested or when appropriate in conversations about the project.

## Recent Changes (as of last update)
- Disabled private database in iCloud
- Updated logging functionality
- Made app work with assets
- Simplified code related to favorites handling after CloudKit DTO processing

## Last Updated
This document should be reviewed and updated regularly to maintain accuracy with the current state of the project.