//
//  SliderExamplesView.swift
//  viewable
//
//  Created by Alexandru Turcanu on 6/15/25.
//

import SwiftUI

// MARK: - Slider Example Components

struct SliderExample: View {
  let title: String
  let slider: AnyView
  let code: String
  let fullCode: String?

  init(title: String, slider: AnyView, code: String, fullCode: String? = nil) {
    self.title = title
    self.slider = slider
    self.code = code
    self.fullCode = fullCode
  }

  var body: some View {
    Section {
      slider
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
      @State private var value: Double = 0.5

      Slider(value: $value)
      \(code == "basic" ? "" : code)
      """
  }
}

// MARK: - Main View

struct SliderExamplesView: View {
  @State private var basicValue: Double = 0.5
  @State private var rangeValue: Double = 50
  @State private var stepValue: Double = 5
  @State private var minValue: Double = 0.2
  @State private var percentValue: Double = 75
  @State private var temperatureValue: Double = 20
  @State private var volumeValue: Double = 0.6
  @State private var brightnessValue: Double = 0.4

  var body: some View {
    Form {
      SliderExample(
        title: "Basic",
        slider: AnyView(Slider(value: $basicValue)),
        code: "Slider(value: $value)",
        fullCode: """
          @State private var value: Double = 0.5

          Slider(value: $value)
          """
      )

      SliderExample(
        title: "Range",
        slider: AnyView(Slider(value: $rangeValue, in: 0...100)),
        code: "Slider(value: $value, in: 0...100)",
        fullCode: """
          @State private var value: Double = 50

          Slider(value: $value, in: 0...100)
          """
      )

      SliderExample(
        title: "Step",
        slider: AnyView(Slider(value: $stepValue, in: 0...10, step: 1)),
        code: "Slider(value: $value, in: 0...10, step: 1)",
        fullCode: """
          @State private var value: Double = 5

          Slider(value: $value, in: 0...10, step: 1)
          """
      )

      SliderExample(
        title: "Min/Max Labels",
        slider: AnyView(
          Slider(value: $minValue, in: 0...1) {
            Text("Opacity")
          } minimumValueLabel: {
            Text("0")
          } maximumValueLabel: {
            Text("1")
          }
        ),
        code: "minimumValueLabel & maximumValueLabel",
        fullCode: """
          @State private var value: Double = 0.2

          Slider(value: $value, in: 0...1) {
            Text("Opacity")
          } minimumValueLabel: {
            Text("0")
          } maximumValueLabel: {
            Text("1")
          }
          """
      )

      SliderExample(
        title: "Tint",
        slider: AnyView(
          Slider(value: $basicValue, in: 0...1)
            .tint(.red)
        ),
        code: ".tint(.red)",
        fullCode: """
          @State private var value: Double = 0.5

          Slider(value: $value, in: 0...1)
            .tint(.red)
          """
      )

      SliderExample(
        title: "Disabled",
        slider: AnyView(
          Slider(value: $basicValue, in: 0...1)
            .disabled(true)
        ),
        code: ".disabled(true)",
        fullCode: """
          @State private var value: Double = 0.5

          Slider(value: $value, in: 0...1)
            .disabled(true)
          """
      )

      Section(header: Text("")) {}
        .headerProminence(.increased)
      Section(header: Text("Examples")) {}
        .headerProminence(.increased)

      SliderExample(
        title: "Percentage",
        slider: AnyView(
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Progress")
              Spacer()
              Text("\(Int(percentValue))%")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Slider(value: $percentValue, in: 0...100)
          }
        ),
        code: "with percentage display",
        fullCode: """
          @State private var value: Double = 75

          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Progress")
              Spacer()
              Text("\\(Int(value))%")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: 0...100)
          }
          """
      )

      SliderExample(
        title: "Temperature",
        slider: AnyView(
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Temperature")
              Spacer()
              Text("\(Int(temperatureValue))°C")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Slider(value: $temperatureValue, in: -10...40) {
              Text("Temperature")
            } minimumValueLabel: {
              Image(systemName: "thermometer.snowflake")
                .foregroundStyle(.blue)
            } maximumValueLabel: {
              Image(systemName: "thermometer.sun")
                .foregroundStyle(.red)
            }
          }
        ),
        code: "with icons and units",
        fullCode: """
          @State private var value: Double = 20

          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text("Temperature")
              Spacer()
              Text("\\(Int(value))°C")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: -10...40) {
              Text("Temperature")
            } minimumValueLabel: {
              Image(systemName: "thermometer.snowflake")
                .foregroundStyle(.blue)
            } maximumValueLabel: {
              Image(systemName: "thermometer.sun")
                .foregroundStyle(.red)
            }
          }
          """
      )

      SliderExample(
        title: "Volume",
        slider: AnyView(
          HStack(spacing: 12) {
            Image(systemName: "speaker.fill")
              .foregroundStyle(.secondary)
            Slider(value: $volumeValue, in: 0...1)
            Image(systemName: "speaker.wave.3.fill")
              .foregroundStyle(.secondary)
          }
        ),
        code: "inline with icons",
        fullCode: """
          @State private var volume: Double = 0.6

          HStack(spacing: 12) {
            Image(systemName: "speaker.fill")
              .foregroundStyle(.secondary)
            Slider(value: $volume, in: 0...1)
            Image(systemName: "speaker.wave.3.fill")
              .foregroundStyle(.secondary)
          }
          """
      )

      SliderExample(
        title: "Brightness",
        slider: AnyView(
          VStack(alignment: .leading, spacing: 8) {
            Text("Brightness")
              .font(.headline)
            HStack(spacing: 12) {
              Image(systemName: "sun.min")
                .foregroundStyle(.secondary)
              Slider(value: $brightnessValue, in: 0...1)
              Image(systemName: "sun.max.fill")
                .foregroundStyle(.yellow)
            }
            Text("\(Int(brightnessValue * 100))%")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        ),
        code: "with title and percentage",
        fullCode: """
          @State private var brightness: Double = 0.4

          VStack(alignment: .leading, spacing: 8) {
            Text("Brightness")
              .font(.headline)
            HStack(spacing: 12) {
              Image(systemName: "sun.min")
                .foregroundStyle(.secondary)
              Slider(value: $brightness, in: 0...1)
              Image(systemName: "sun.max.fill")
                .foregroundStyle(.yellow)
            }
            Text("\\(Int(brightness * 100))%")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          """
      )
    }
    .formStyle(.grouped)
  }
}

// MARK: - Previews

#Preview("All Examples") {
  NavigationStack {
    SliderExamplesView()
  }
}
