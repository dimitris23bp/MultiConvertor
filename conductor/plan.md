# Add Done Button to Decimal Pad

## Objective
Provide a "Done" button on top of the decimal pad keyboard in `DoubleNumberTextField` so users can easily dismiss it without needing to swipe down.

## Changes
1. **`MultiConvertor/Views/Modals/DoubleNumberTextField.swift`**:
   - In `makeUIView`, create a `UIToolbar` containing a flexible space and a "Done" button.
   - Assign the toolbar to the `textField.inputAccessoryView`.
   - In `Coordinator`, add an `@objc func doneButtonTapped()` that resigns the first responder by calling `UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)`.
   - Set the `doneButton`'s target to `context.coordinator` and action to `#selector(Coordinator.doneButtonTapped)`.

## Verification (Completed)
- [x] Open the app, focus on a `DoubleNumberTextField` to bring up the decimal pad.
- [x] Verify the "Done" button appears on the right side of a toolbar above the keyboard.
- [x] Tap "Done" and verify the keyboard dismisses.