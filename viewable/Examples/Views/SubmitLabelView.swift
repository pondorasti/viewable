//
//  SubmitLabelView.swift
//  viewable
//
//  Created by Alexandru Turcanu on 6/15/25.
//

import SwiftUI

// MARK: - Submit Label Example

struct SubmitLabelExample: View {
  let title: String
  let submitLabel: SubmitLabel
  let placeholder: String
  let code: String

  @State private var text: String = ""

  init(
    title: String, submitLabel: SubmitLabel, placeholder: String, code: String
  ) {
    self.title = title
    self.submitLabel = submitLabel
    self.placeholder = placeholder
    self.code = code
  }

  var body: some View {
    Section {
      TextField(placeholder, text: $text)
        .submitLabel(submitLabel)
        .contextMenu {
          Button("Copy Code") {
            generateCodeSnippet().copyToClipboard()
          }
        }
    } header: {
      Text(title)
    } footer: {
      Text(".submitLabel(.\(code))")
        .font(.system(.caption2, design: .monospaced))
        .foregroundStyle(.secondary)
    }
  }

  private func generateCodeSnippet() -> String {
    return """
      @State private var text: String = ""

      TextField("\(placeholder)", text: $text)
        .submitLabel(.\(code))
      """
  }
}

// MARK: - Main View

struct SubmitLabelView: View {
  var body: some View {
    Group {
      #if os(iOS) || os(tvOS)
        submitLabelsForm
      #else
        UnavailableFeatureView(feature: "submitLabel(_:)")
      #endif
    }
  }

  #if os(iOS) || os(tvOS)
    private var submitLabelsForm: some View {
      Form {
        SubmitLabelExample(
          title: "Send",
          submitLabel: .send,
          placeholder: "Type a message",
          code: "send"
        )

        SubmitLabelExample(
          title: "Continue",
          submitLabel: .continue,
          placeholder: "Continue",
          code: "continue"
        )

        SubmitLabelExample(
          title: "Go",
          submitLabel: .go,
          placeholder: "Go",
          code: "go"
        )

        SubmitLabelExample(
          title: "Return",
          submitLabel: .return,
          placeholder: "Return",
          code: "return"
        )

        SubmitLabelExample(
          title: "Route",
          submitLabel: .route,
          placeholder: "Route",
          code: "route"
        )

        SubmitLabelExample(
          title: "Next",
          submitLabel: .next,
          placeholder: "Next",
          code: "next"
        )

        SubmitLabelExample(
          title: "Join",
          submitLabel: .join,
          placeholder: "Join",
          code: "join"
        )

        SubmitLabelExample(
          title: "Done",
          submitLabel: .done,
          placeholder: "Done",
          code: "done"
        )

        SubmitLabelExample(
          title: "Search",
          submitLabel: .search,
          placeholder: "Search",
          code: "search"
        )
      }
      .formStyle(.grouped)
    }
  #endif
}

// MARK: - Previews

#Preview("All Submit Labels") {
  NavigationStack {
    SubmitLabelView()
  }
}
