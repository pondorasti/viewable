//  ListExamplesView.swift
//  viewable
//
//  Created by Alexandru Turcanu on 6/17/25.
//

import SwiftUI

// MARK: - Supported Styles

/// All list styles showcased in the example view.
enum ListStyleKind: String, CaseIterable, Identifiable {
  case automatic
  case plain
  case grouped
  case inset
  case insetGrouped
  case sidebar
  case bordered

  var id: String { rawValue }

  /// Human-readable title.
  var title: String {
    switch self {
    case .automatic: return "Automatic"
    case .plain: return "Plain"
    case .grouped: return "Grouped"
    case .inset: return "Inset"
    case .insetGrouped: return "Inset Grouped"
    case .sidebar: return "Sidebar"
    case .bordered: return "Bordered"
    }
  }

  /// Code snippet for the style modifier.
  var codeSnippet: String {
    return ".listStyle(.\(rawValue))"
  }
}

// MARK: - Sample List View

/// A stand-alone list that applies the provided style.
struct ListStyleSampleView: View {
  let kind: ListStyleKind

  private var list: some View {
    List {
      Section("Fruits") {
        Text("Apple")
        Text("Banana")
        Text("Orange")
        Text("Grapes")
        Text("Strawberry")
      }

      Section("Vegetables") {
        Label("Carrot", systemImage: "carrot")
        Label("Broccoli", systemImage: "tree")
        Label("Spinach", systemImage: "leaf")
        Label("Tomato", systemImage: "t.circle")
        Label("Cucumber", systemImage: "c.circle")
      }

      // Section with a label header (text + icon)
      Section {
        Label("Milk", systemImage: "drop")
        Label("Cheese", systemImage: "birthday.cake")
        Label("Yogurt", systemImage: "cup.and.saucer")
      } header: {
        Text("Dairy")
      } footer: {
        Text("Calcium-rich dairy products.")
      }

      // Another label-based section to increase length
      Section {
        Label("Water", systemImage: "drop")
        Label("Tea", systemImage: "mug")
        Label("Coffee", systemImage: "cup.and.saucer.fill")
        Label("Juice", systemImage: "takeoutbag.and.cup.and.straw")
        Label("Soda", systemImage: "s.circle")
      } header: {
        Label("Drinks", systemImage: "cup.and.saucer")
      } footer: {
        Text("Stay hydrated with your favorite drinks.")
      }
    }
  }

  var body: some View {
    // Apply the chosen style – the switch keeps the generic `some View` type intact.
    Group {
      switch kind {
      case .automatic: list
      case .plain: list.listStyle(.plain)
      case .grouped:
        #if os(macOS)
          UnavailableFeatureView(feature: ".grouped")
        #else
          list.listStyle(.grouped)
        #endif
      case .inset: list.listStyle(.inset)
      case .insetGrouped:
        #if os(macOS)
          UnavailableFeatureView(feature: ".insetGrouped")
        #else
          list.listStyle(.insetGrouped)
        #endif
      case .sidebar: list.listStyle(.sidebar)
      case .bordered:
        #if os(macOS)
          list.listStyle(.bordered)
        #else
          UnavailableFeatureView(feature: ".bordered")
        #endif
      }
    }
  }
}

// MARK: - Row Helper

/// Row displayed in the overview page; tapping it navigates to the sample list.
private struct ListStyleRow: View {
  let kind: ListStyleKind

  var body: some View {
    NavigationLink {
      ListStyleSampleView(kind: kind)
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
    switch kind {
    case .automatic:
      return """
        List {
          // …
        }
        """
    case .grouped, .insetGrouped:
      fallthrough
    default:
      return """
        List {
          // …
        }
        .listStyle(.\(kind.rawValue))
        """
    }
  }
}

// MARK: - Main View

struct ListStyleView: View {
  var body: some View {
    Form {
      ForEach(ListStyleKind.allCases) { kind in
        Section {
          ListStyleRow(kind: kind)
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

// MARK: - Preview

#Preview("All List Styles") {
  NavigationStack {
    ListStyleView()
  }
}
