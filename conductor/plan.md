# Smart Logger Wrapper Plan

## Objective
Implement a smart logging wrapper around `OSLog` (`Logger`) to provide a frictionless developer experience. The wrapper will automatically format log variables as `.public` during debugging (Debug builds) and `.private` during production (Release builds). This resolves the issue of variable values appearing as `<private>` in Xcode while adhering to Apple's privacy-first logging standards in production.

## Key Files & Context
- `CryptoConverter/Loggers.swift`: The central file defining the application's logger instances. The wrapper extension will be added here.

## Implementation Steps

1. **Extend `Logger` in `Loggers.swift`:**
   - Add an `extension Logger` block.
   - Implement custom log methods for standard log levels: `debugApp`, `infoApp`, `warningApp`, and `errorApp`.
   - Within each custom method, use the `#if DEBUG` compiler directive:
     - If `DEBUG`, log the provided string interpolation with `privacy: .public`.
     - Else (Release), log the provided string interpolation with `privacy: .private`.

2. **Refactor Existing Log Calls:**
   - Search the codebase for existing usages of the `Logger` and replace standard `Logger` method calls with the new smart wrapper methods.
   - Remove any existing explicit `privacy: .public` tags.

## Verification & Testing
1. **Debug Build Verification:**
   - Run the application using the Debug configuration.
   - Verify in the Xcode console that variable values are clearly visible.

2. **Release Build / Privacy Verification:**
   - Run the app using the Release configuration.
   - Verify that the variables are masked as `<private>`.