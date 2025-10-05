
import SwiftUI
import UIKit

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

        init(_ parent: DoubleNumberTextField) {
            self.parent = parent
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            // Store the cursor's logical position
            let originalText = textField.text ?? ""
            guard let selectedRange = textField.selectedTextRange else { return }
            let cursorOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            let textBeforeCursor = String(originalText.prefix(cursorOffset))
            let separatorsBefore = textBeforeCursor.filter { String($0) == parent.formatter.groupingSeparator }.count
            
            let unformattedText = originalText.replacingOccurrences(of: parent.formatter.groupingSeparator, with: "")
            textField.text = unformattedText
            
            // Restore cursor position
            let newCursorOffset = cursorOffset - separatorsBefore
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorOffset) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
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
            // 1. Get original state
            let originalText = textField.text ?? ""
            guard let selectedRange = textField.selectedTextRange else { return false }
            let cursorOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)

            // Ignore typing of grouping separators
            if string == parent.formatter.groupingSeparator {
                return false
            }
            
            // 2. Calculate the new unformatted text and the cursor's new logical position
            let newText = (originalText as NSString).replacingCharacters(in: range, with: string)
            
            // If user is typing a decimal separator, just update the value and text
            if string == parent.formatter.decimalSeparator {
                if originalText.contains(string) { return false }
                parent.value = parent.formatter.number(from: newText)?.doubleValue ?? 0.0
                textField.text = newText
                
                // Set cursor position after the separator
                if let newPosition = textField.position(from: textField.beginningOfDocument, offset: cursorOffset + string.count) {
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
                return false
            }
            
            let unformattedText = newText.replacingOccurrences(of: parent.formatter.groupingSeparator, with: "")
            
            // 3. Update the parent's value
            if let number = parent.formatter.number(from: unformattedText) {
                parent.value = number.doubleValue
            } else if unformattedText.isEmpty {
                parent.value = 0
            } else {
                // Not a valid number, reject the change
                return false
            }
            
            // 4. Format the text and calculate the new cursor position
            let formattedText = parent.formatter.string(from: NSNumber(value: parent.value)) ?? ""
            
            let addedChars = string.count - range.length
            let logicalCursorOffset = cursorOffset + addedChars
            
            var physicalCursorOffset = 0
            var logicalCharsCounted = 0
            
            for char in formattedText {
                if logicalCharsCounted < logicalCursorOffset {
                    physicalCursorOffset += 1
                    if String(char) != parent.formatter.groupingSeparator {
                        logicalCharsCounted += 1
                    }
                } else {
                    break
                }
            }
            
            // This handles a specific case where typing at the beginning can misplace the cursor
            if logicalCursorOffset == 1 && physicalCursorOffset == 2 && formattedText.count > 1 {
                 if String(formattedText.prefix(1)) == parent.formatter.groupingSeparator {
                     physicalCursorOffset = 1
                 }
            }

            // 5. Set the new text and cursor position
            textField.text = formattedText
            
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: physicalCursorOffset) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            
            return false // We handled the change manually
        }
    }
}
