//  HeaderProminenceView.swift
//  viewable
//
//  Created by Alexandru Turcanu on 10/31/25.
//

import SwiftUI

// MARK: - Supported Prominence Levels

/// All header prominence levels showcased in the example view.
private enum ProminenceKind: String, CaseIterable, Identifiable {
  case standard
  case increased

  var id: String { rawValue }

  /// Human-readable title.
  var title: String {
    switch self {
    case .standard: return "Standard"
    case .increased: return "Increased"
    }
  }

  /// Code snippet for the prominence modifier.
  var codeSnippet: String {
    return ".headerProminence(.\(rawValue))"
  }
}

// MARK: - Sample List View

/// A stand-alone list that applies the provided header prominence.
private struct SampleListView: View {
  let kind: ProminenceKind

  private var list: some View {
    Form {
      Section("Featured Items") {
        Label("New Release", systemImage: "star.fill")
        Label("Editor's Choice", systemImage: "rosette")
        Label("Trending Now", systemImage: "chart.line.uptrend.xyaxis")
        Label("Top Rated", systemImage: "trophy.fill")
      }

      Section("Categories") {
        Label("Productivity", systemImage: "checklist")
        Label("Entertainment", systemImage: "tv")
        Label("Education", systemImage: "book")
        Label("Lifestyle", systemImage: "heart")
        Label("Games", systemImage: "gamecontroller")
      }

      Section("Additional Options") {
        Label("Export Data", systemImage: "square.and.arrow.up")
        Label("Import Data", systemImage: "square.and.arrow.down")
        Label("Sync", systemImage: "arrow.triangle.2.circlepath")
        Label("Backup", systemImage: "externaldrive")
      }

      Section {
        Label("Account Settings", systemImage: "person.circle")
        Label("Privacy", systemImage: "lock")
        Label("Notifications", systemImage: "bell")
        Label("Appearance", systemImage: "paintbrush")
      } header: {
        Label("Settings", systemImage: "gearshape")
      }
    }
    .formStyle(.grouped)
  }

  var body: some View {
    // Apply the chosen prominence
    Group {
      switch kind {
      case .standard:
        list.headerProminence(.standard)
      case .increased:
        list.headerProminence(.increased)
      }
    }
    .navigationTitle(kind.title)
  }
}

// MARK: - Row Helper

/// Row displayed in the overview page; tapping it navigates to the sample list.
private struct HeaderProminenceRow: View {
  let kind: ProminenceKind

  var body: some View {
    NavigationLink {
      SampleListView(kind: kind)
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
    return """
    List {
      Section("Header") {
        // …
      }
    }
    .headerProminence(.\(kind.rawValue))
    """
  }
}

// MARK: - Main View

struct HeaderProminenceView: View {
  var body: some View {
    Form {
      ForEach(ProminenceKind.allCases) { kind in
        Section {
          HeaderProminenceRow(kind: kind)
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

#Preview("Header Prominence Levels") {
  NavigationStack {
    HeaderProminenceView()
  }
}
