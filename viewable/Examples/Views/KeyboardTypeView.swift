//
//  KeyboardTypeView.swift
//  viewable
//
//  Created by Alexandru Turcanu on 6/15/25.
//

import SwiftUI

#if os(iOS)
  import UIKit
#endif

// MARK: - Keyboard Type Example

struct KeyboardTypeExample: View {
  let title: String
  #if os(iOS)
    let keyboardType: UIKeyboardType
  #endif
  let placeholder: String
  let code: String

  @State private var text: String = ""

  #if os(iOS)
    init(
      title: String, keyboardType: UIKeyboardType, placeholder: String, code: String
    ) {
      self.title = title
      self.keyboardType = keyboardType
      self.placeholder = placeholder
      self.code = code
    }
  #else
    init(title: String, placeholder: String, code: String) {
      self.title = title
      self.placeholder = placeholder
      self.code = code
    }
  #endif

  var body: some View {
    Section {
      TextField(placeholder, text: $text)
        #if os(iOS)
          .keyboardType(keyboardType)
        #endif
        .contextMenu {
          Button("Copy Code") {
            generateCodeSnippet().copyToClipboard()
          }
        }
    } header: {
      Text(title)
    } footer: {
      Text(".keyboardType(.\(code))")
        .font(.system(.caption2, design: .monospaced))
        .foregroundStyle(.secondary)
    }
  }

  private func generateCodeSnippet() -> String {
    return """
      @State private var text: String = ""

      TextField("\(placeholder)", text: $text)
        .keyboardType(.\(code))
      """
  }
}

// MARK: - Main View

struct KeyboardTypeView: View {
  var body: some View {
    Group {
      #if os(iOS)
        keyboardTypesForm
      #else
        UnavailableFeatureView(feature: "keyboardType(_:)")
      #endif
    }
  }

  #if os(iOS)
    private var keyboardTypesForm: some View {
      Form {
        KeyboardTypeExample(
          title: "Default",
          keyboardType: .default,
          placeholder: "Type something",
          code: "default"
        )

        KeyboardTypeExample(
          title: "Number Pad",
          keyboardType: .numberPad,
          placeholder: "Enter a passcode",
          code: "numberPad"
        )

        KeyboardTypeExample(
          title: "Decimal Pad",
          keyboardType: .decimalPad,
          placeholder: "Enter a decimal number",
          code: "decimalPad"
        )

        KeyboardTypeExample(
          title: "Phone Pad",
          keyboardType: .phonePad,
          placeholder: "Enter a phone number",
          code: "phonePad"
        )

        KeyboardTypeExample(
          title: "Name Phone Pad",
          keyboardType: .namePhonePad,
          placeholder: "Enter name or phone number",
          code: "namePhonePad"
        )

        KeyboardTypeExample(
          title: "Email Address",
          keyboardType: .emailAddress,
          placeholder: "Enter your email",
          code: "emailAddress"
        )

        KeyboardTypeExample(
          title: "Twitter",
          keyboardType: .twitter,
          placeholder: "Compose a tweet",
          code: "twitter"
        )

        KeyboardTypeExample(
          title: "URL",
          keyboardType: .URL,
          placeholder: "Enter URL",
          code: "URL"
        )

        KeyboardTypeExample(
          title: "Web Search",
          keyboardType: .webSearch,
          placeholder: "Search",
          code: "webSearch"
        )

        KeyboardTypeExample(
          title: "Numbers and Punctuation",
          keyboardType: .numbersAndPunctuation,
          placeholder: "Enter license code",
          code: "numbersAndPunctuation"
        )

        KeyboardTypeExample(
          title: "ASCII Capable",
          keyboardType: .asciiCapable,
          placeholder: "Type something",
          code: "asciiCapable"
        )

        KeyboardTypeExample(
          title: "ASCII Capable Number Pad",
          keyboardType: .asciiCapableNumberPad,
          placeholder: "Type something",
          code: "asciiCapableNumberPad"
        )
      }
      .formStyle(.grouped)
    }
  #endif
}

// MARK: - Previews

#Preview("All Keyboard Types") {
  NavigationStack {
    KeyboardTypeView()
  }
}
