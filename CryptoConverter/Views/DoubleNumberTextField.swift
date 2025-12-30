import SwiftUI
import UIKit

// BUG: If I have typed something on a field, then I remove them all, then the value that is left is zero. On that zero, if I never lose the focus of the field and I type again, it will type a number before the zero. So if I type '7', it will say '70'. Then if I type '8', instead of '708', it will type '780'.
struct DoubleNumberTextField: UIViewRepresentable {
    @Binding var value: Double
    let formatter: NumberFormatter

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .decimalPad
        textField.textAlignment = .right
        textField.font = UIFont.systemFont(ofSize: 18)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if !uiView.isFirstResponder {
            let text = formatter.string(from: NSNumber(value: value))
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: DoubleNumberTextField
        var didBeginEditing = true

        init(_ parent: DoubleNumberTextField) {
            self.parent = parent
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            didBeginEditing = true
            DispatchQueue.main.async {
                // Move cursor to the end of the text
                if let newPosition = textField.position(from: textField.endOfDocument, offset: 0) {
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            // When editing ends, commit the final value and format it.
            let unformattedText = (textField.text ?? "").replacingOccurrences(of: parent.formatter.groupingSeparator, with: "")
            let number = parent.formatter.number(from: unformattedText)
            parent.value = number?.doubleValue ?? 0.0
            textField.text = parent.formatter.string(from: NSNumber(value: parent.value))
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // If first typing after focus and the string is a digit, replace all text with this digit only
            if didBeginEditing && !string.isEmpty && string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                didBeginEditing = false
                // Update parent's value
                if let number = parent.formatter.number(from: string) {
                    parent.value = number.doubleValue
                } else {
                    parent.value = 0
                }
                // Set text to the newly typed digit only
                textField.text = string
                // Move cursor to the end
                if let newPosition = textField.position(from: textField.beginningOfDocument, offset: string.count) {
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
                return false
            }

            // 1. Get original state
            let originalText = textField.text ?? ""
            guard let selectedRange = textField.selectedTextRange else { return false }
            let cursorOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)

            // Ignore typing of grouping separators
            if string == parent.formatter.groupingSeparator {
                return false
            }
            
            let decimalSeparator = parent.formatter.decimalSeparator ?? "."
            let newText = (originalText as NSString).replacingCharacters(in: range, with: string)

            // Enforce fraction digit limit
            let components = newText.components(separatedBy: decimalSeparator)
            if components.count > 1 {
                let fractionalPart = components[1]
                if fractionalPart.count > parent.formatter.maximumFractionDigits && !string.isEmpty {
                    return false
                }
            }
            
            // Determine if the edit is happening in the fractional part of the number.
            var isEditingFractionalPart = false
            if let decimalRange = originalText.range(of: decimalSeparator) {
                let decimalPosition = originalText.distance(from: originalText.startIndex, to: decimalRange.lowerBound)
                if range.location > decimalPosition {
                    isEditingFractionalPart = true
                }
            }
            // Also true if the user is adding the decimal separator itself
            if string == decimalSeparator {
                if originalText.contains(string) { return false } // Don't allow multiple separators
                isEditingFractionalPart = true
            }

            let unformattedText = newText.replacingOccurrences(of: parent.formatter.groupingSeparator, with: "")

            // 2. Update the parent's value
            if let number = parent.formatter.number(from: unformattedText) {
                parent.value = number.doubleValue
            } else if unformattedText.isEmpty {
                parent.value = 0
            } else {
                // Not a valid number, reject the change
                return false
            }

            // 3. Set the text in the field
            let textToSet: String
            if isEditingFractionalPart {
                let components = unformattedText.components(separatedBy: decimalSeparator)
                let integerPartString = components.first ?? ""
                
                // Format the integer part to get grouping separators
                let integerNumber = parent.formatter.number(from: integerPartString) ?? 0
                let formattedIntegerPart = parent.formatter.string(from: integerNumber) ?? integerPartString
                
                if components.count > 1 {
                    let fractionalPartString = components[1]
                    textToSet = formattedIntegerPart + decimalSeparator + fractionalPartString
                } else {
                    // This happens when the user types the decimal separator for the first time
                    textToSet = formattedIntegerPart + decimalSeparator
                }
            } else {
                // For the integer part, re-format from the number to get grouping separators.
                textToSet = parent.formatter.string(from: NSNumber(value: parent.value)) ?? ""
            }
            
            textField.text = textToSet

            // 4. Calculate and set the new cursor position
            let addedChars = string.count - range.length
            // The cursor position in the unformatted string
            let logicalCursorOffset = cursorOffset - (originalText.prefix(cursorOffset).filter { String($0) == parent.formatter.groupingSeparator }.count) + addedChars
            
            var physicalCursorOffset = 0
            var logicalCharsCounted = 0
            
            for char in textToSet {
                if logicalCharsCounted < logicalCursorOffset {
                    physicalCursorOffset += 1
                    if String(char) != parent.formatter.groupingSeparator {
                        logicalCharsCounted += 1
                    }
                } else {
                    break
                }
            }
            
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: physicalCursorOffset) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            
            return false // We handled the change manually
        }
    }
}
