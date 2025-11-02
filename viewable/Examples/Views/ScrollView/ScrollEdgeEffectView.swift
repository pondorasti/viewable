//
//  ScrollEdgeEffectView.swift
//  viewable
//
//  Created by Alexandru Turcanu on 6/15/25.
//

import SwiftUI

// MARK: - Supported Styles

/// All scroll edge effect combinations showcased in the example view.
private enum ScrollEdgeEffectKind: String, CaseIterable, Identifiable {
  case softTop
  case hardTop
  case softBottom
  case hardBottom

  var id: String { rawValue }

  /// Human-readable title.
  var title: String {
    switch self {
    case .softTop: return "Soft Top"
    case .hardTop: return "Hard Top"
    case .softBottom: return "Soft Bottom"
    case .hardBottom: return "Hard Bottom"
    }
  }

  /// Scroll edge effect style.
  var style: ScrollEdgeEffectStyle {
    switch self {
    case .softTop, .softBottom: return .soft
    case .hardTop, .hardBottom: return .hard
    }
  }

  /// Edge for the effect.
  var edge: Edge.Set {
    switch self {
    case .softTop, .hardTop: return .top
    case .softBottom, .hardBottom: return .bottom
    }
  }

  /// Code snippet for the style modifier.
  var codeSnippet: String {
    let styleName = style == .soft ? "soft" : "hard"
    let edgeName = edge == .top ? "top" : "bottom"
    return ".scrollEdgeEffectStyle(.\(styleName), for: .\(edgeName))"
  }
}

// MARK: - Sample List View

/// A stand-alone list that applies the provided scroll edge effect.
private struct SampleScrollEdgeEffectView: View {
  let kind: ScrollEdgeEffectKind

  var body: some View {
    List {
      ForEach(0..<100, id: \.self) { index in
        Text("Item \(index)")
      }
    }
    .scrollEdgeEffectStyle(kind.style, for: kind.edge)
    #if !os(macOS)
      .toolbar {
        ToolbarItemGroup(placement: .bottomBar) {
          Button(action: {}) {
            Label("Action", systemImage: "star.fill")
          }
          Spacer()
          Button(action: {}) {
            Label("Share", systemImage: "square.and.arrow.up")
          }
        }
      }
    #endif
  }
}

// MARK: - Row Helper

/// Row displayed in the overview page; tapping it navigates to the sample view.
private struct ScrollEdgeEffectRow: View {
  let kind: ScrollEdgeEffectKind

  var body: some View {
    NavigationLink {
      SampleScrollEdgeEffectView(kind: kind)
    } label: {
      Text(kind.title)
    }
    .contextMenu {
      Button("Copy Code") {
        generateCodeSnippet().copyToClipboard()
      }
    }
  }

  private func generateCodeSnippet() -> String {
    let styleName = kind.style == .soft ? "soft" : "hard"
    let edgeName = kind.edge == .top ? "top" : "bottom"
    return """
      List {
        ForEach(0..<100, id: \\.self) { index in
          Text("Item \\(index)")
        }
      }
      .scrollEdgeEffectStyle(.\(styleName), for: .\(edgeName))
      """
  }
}

// MARK: - Main View

struct ScrollEdgeEffectView: View {
  var body: some View {
    Form {
      ForEach(ScrollEdgeEffectKind.allCases) { kind in
        Section {
          ScrollEdgeEffectRow(kind: kind)
        } footer: {
          Text(kind.codeSnippet)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(.secondary)
        }
      }
    }
    .formStyle(.grouped)
  }
}

// MARK: - Previews

#Preview("All Scroll Edge Effects") {
  NavigationStack {
    ScrollEdgeEffectView()
  }
}
