//
//  ToggleExamplesView.swift
//  viewable
//
//  Created by Alexandru Turcanu on 6/15/25.
//

import SwiftUI

// MARK: - Toggle Example Components

struct ToggleExample: View {
  let title: String
  let toggle: AnyView
  let code: String
  let fullCode: String?

  init(title: String, toggle: AnyView, code: String, fullCode: String? = nil) {
    self.title = title
    self.toggle = toggle
    self.code = code
    self.fullCode = fullCode
  }

  var body: some View {
    Section {
      toggle
        .contextMenu {
          Button("Copy Code") {
            (fullCode ?? generateDefaultCode()).copyToClipboard()
          }
        }
    } header: {
      Text(title)
    } footer: {
      Text(code)
        .font(.system(.caption2, design: .monospaced))
        .foregroundStyle(.secondary)
    }
  }

  private func generateDefaultCode() -> String {
    return """
    @State private var isOn: Bool = false

    Toggle("Toggle", isOn: $isOn)
    \(code == "basic" ? "" : code)
    """
  }
}

// MARK: - Main View

struct ToggleExamplesView: View {
  @State private var basicToggle: Bool = false
  @State private var switchToggle: Bool = true
  @State private var checkboxToggle: Bool = false
  @State private var buttonToggle: Bool = true
  @State private var labelToggle: Bool = true
  @State private var tintToggle: Bool = true
  @State private var disabledToggle: Bool = false

  var body: some View {
    Form {
      ToggleExample(
        title: "Basic",
        toggle: AnyView(Toggle("Toggle", isOn: $basicToggle)),
        code: "Toggle(\"Toggle\", isOn: $isOn)",
        fullCode: """
        @State private var isOn: Bool = false

        Toggle("Toggle", isOn: $isOn)
        """
      )

      ToggleExample(
        title: "Switch Style",
        toggle: AnyView(Toggle("Switch", isOn: $switchToggle).toggleStyle(.switch)),
        code: ".toggleStyle(.switch)",
        fullCode: """
        @State private var isOn: Bool = false

        Toggle("Switch", isOn: $isOn)
          .toggleStyle(.switch)
        """
      )

#if os(macOS)
      ToggleExample(
        title: "Checkbox Style",
        toggle: AnyView(Toggle("Checkbox", isOn: $checkboxToggle).toggleStyle(.checkbox)),
        code: ".toggleStyle(.checkbox)",
        fullCode: """
        @State private var isOn: Bool = false

        Toggle("Checkbox", isOn: $isOn)
          .toggleStyle(.checkbox)
        """
      )
#endif

      ToggleExample(
        title: "Button Style",
        toggle: AnyView(Toggle("Button", isOn: $buttonToggle).toggleStyle(.button)),
        code: ".toggleStyle(.button)",
        fullCode: """
        @State private var isOn: Bool = false

        Toggle("Button", isOn: $isOn)
          .toggleStyle(.button)
        """
      )

      ToggleExample(
        title: "Label",
        toggle: AnyView(
          Toggle(isOn: $labelToggle) {
            Label("Wi-Fi", systemImage: "wifi")
          }
        ),
        code: "Toggle(isOn: $isOn) { Label(...) }",
        fullCode: """
        @State private var isOn: Bool = false

        Toggle(isOn: $isOn) {
          Label("Wi-Fi", systemImage: "wifi")
        }
        """
      )

      ToggleExample(
        title: "Tint",
        toggle: AnyView(
          Toggle("Custom Color", isOn: $tintToggle)
            .tint(.purple)
        ),
        code: ".tint(.purple)",
        fullCode: """
        @State private var isOn: Bool = false

        Toggle("Custom Color", isOn: $isOn)
          .tint(.purple)
        """
      )

      ToggleExample(
        title: "Disabled",
        toggle: AnyView(
          Toggle("Disabled Toggle", isOn: $disabledToggle)
            .disabled(true)
        ),
        code: ".disabled(true)",
        fullCode: """
        @State private var isOn: Bool = false

        Toggle("Disabled Toggle", isOn: $isOn)
          .disabled(true)
        """
      )
    }
    .formStyle(.grouped)
  }
}

// MARK: - Previews

#Preview("All Examples") {
  NavigationStack {
    ToggleExamplesView()
  }
}
