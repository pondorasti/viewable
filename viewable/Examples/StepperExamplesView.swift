//
//  StepperExamplesView.swift
//  viewable
//
//  Created by Alexandru Turcanu on 6/15/25.
//

import SwiftUI

// MARK: - Stepper Example Components

struct StepperExample: View {
  let title: String
  let stepper: AnyView
  let code: String
  let fullCode: String?

  init(title: String, stepper: AnyView, code: String, fullCode: String? = nil) {
    self.title = title
    self.stepper = stepper
    self.code = code
    self.fullCode = fullCode
  }

  var body: some View {
    Section {
      stepper
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
      @State private var value: Int = 0

      Stepper("Value: \\(value)", value: $value)
      \(code == "basic" ? "" : code)
      """
  }
}

// MARK: - Main View

struct StepperExamplesView: View {
  @State private var basicValue: Int = 5
  @State private var rangeValue: Int = 3
  @State private var stepValue: Int = 10
  @State private var customValue: Int = 64
  @State private var disabledValue: Int = 0
  @State private var labelValue: Int = 8

  var body: some View {
    Form {
      StepperExample(
        title: "Basic",
        stepper: {
          Stepper("Value: \(basicValue)", value: $basicValue)
        },
        code: "Stepper(\"Value: \\(value)\", value: $value)",
        fullCode: """
          @State private var value: Int = 5

          Stepper("Value: \\(value)", value: $value)
          """
      )

      StepperExample(
        title: "Range",
        stepper: {
          Stepper("Count: \(rangeValue)", value: $rangeValue, in: 0...10)
        },
        code: "Stepper(\"...\", value: $value, in: 0...10)",
        fullCode: """
          @State private var value: Int = 3

          Stepper("Count: \\(value)", value: $value, in: 0...10)
          """
      )

      StepperExample(
        title: "Step",
        stepper: {
          Stepper("Step: \(stepValue)", value: $stepValue, step: 5)
        },
        code: "Stepper(\"...\", value: $value, step: 5)",
        fullCode: """
          @State private var value: Int = 10

          Stepper("Step: \\(value)", value: $value, step: 5)
          """
      )

      StepperExample(
        title: "Custom Actions",
        stepper: {
          Stepper("Custom: \(customValue)") {
            customValue *= 2
          } onDecrement: {
            customValue /= 2
          }
        },
        code: "Stepper with custom onIncrement/onDecrement",
        fullCode: """
          @State private var value: Int = 4

          Stepper("Custom: \\(value)") {
            value *= 2
          } onDecrement: {
            value /= 2
          }
          """
      )

      StepperExample(
        title: "Label",
        stepper: {
          Stepper(value: $labelValue) {
            Label("Volume: \(labelValue)", systemImage: "speaker.wave.2")
          }
        },
        code: "Stepper(value: $value) { Label(...) }",
        fullCode: """
          @State private var value: Int = 8

          Stepper("Value: \\(value)", value: $value, in: 1...10) {
            Label("Volume", systemImage: "speaker.wave.2")
          }
          """
      )

      StepperExample(
        title: "Disabled",
        stepper: {
          Stepper("Disabled: \(disabledValue)", value: $disabledValue)
            .disabled(true)
        },
        code: ".disabled(true)",
        fullCode: """
          @State private var value: Int = 0

          Stepper("Disabled: \\(value)", value: $value)
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
    StepperExamplesView()
  }
}
