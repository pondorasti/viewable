//
//  ColorPickerExamplesView.swift
//  viewable
//
//  Created by Alexandru Turcanu on 12/17/24.
//

import SwiftUI

// MARK: - ColorPicker Example Components

struct ColorPickerExample: View {
  let title: String
  let colorPicker: AnyView
  let code: String
  let fullCode: String?
  
  init(title: String, colorPicker: AnyView, code: String, fullCode: String? = nil) {
    self.title = title
    self.colorPicker = colorPicker
    self.code = code
    self.fullCode = fullCode
  }
  
  var body: some View {
    Section {
      colorPicker
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
@State private var selectedColor: Color = .blue

ColorPicker("Select Color", selection: $selectedColor)
\(code == "basic" ? "" : code)
"""
  }
}

// MARK: - Main View

struct ColorPickerExamplesView: View {
  @State private var basicColor: Color = .blue
  @State private var noOpacityColor: Color = .purple
  @State private var disabledColor: Color = .orange
  @State private var customLabelColor: Color = .teal
  
  var body: some View {
    Form {
      ColorPickerExample(
        title: "Basic",
        colorPicker: AnyView(ColorPicker("Select Color", selection: $basicColor)),
        code: "ColorPicker(\"Select Color\", selection: $color)",
        fullCode: """
@State private var selectedColor: Color = .blue

ColorPicker("Select Color", selection: $selectedColor)
"""
      )
      
      ColorPickerExample(
        title: "Without Opacity",
        colorPicker: AnyView(
          ColorPicker("No Opacity", selection: $noOpacityColor, supportsOpacity: false)
        ),
        code: "ColorPicker(\"...\", selection: $color, supportsOpacity: false)",
        fullCode: """
@State private var selectedColor: Color = .purple

ColorPicker("No Opacity", selection: $selectedColor, supportsOpacity: false)
"""
      )
      
      ColorPickerExample(
        title: "Label",
        colorPicker: AnyView(
          ColorPicker(selection: $customLabelColor) {
            Label("Theme Color", systemImage: "paintbrush.fill")
          }
        ),
        code: "ColorPicker(selection: $color) { Label(...) }",
        fullCode: """
@State private var selectedColor: Color = .teal

ColorPicker(selection: $selectedColor) {
  Label("Theme Color", systemImage: "paintbrush.fill")
    .foregroundColor(selectedColor)
}
"""
      )
      
      ColorPickerExample(
        title: "Disabled",
        colorPicker: AnyView(
          ColorPicker("Disabled Color", selection: $disabledColor)
            .disabled(true)
        ),
        code: ".disabled(true)",
        fullCode: """
@State private var selectedColor: Color = .orange

ColorPicker("Disabled Color", selection: $selectedColor)
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
    ColorPickerExamplesView()
  }
} 
