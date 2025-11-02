import SwiftUI

// MARK: - Gradient View

struct AnyDistanceMetalGradientView: View {
  let page: Int
  let startDate = Date()

  var body: some View {
    TimelineView(.animation) { context in
      let time = startDate.distance(to: context.date)

      Rectangle()
        .fill(.black)
        .visualEffect { content, proxy in
          content
            .colorEffect(
              ShaderLibrary.animatedGradient(
                .float(time),
                .float2(proxy.size),
                .float(Float(page))
              )
            )
        }
    }
  }
}

// MARK: - Showcase View

struct AnyDistanceMetalGradientShowcaseView: View {
  @Environment(\.openURL) private var openURL

  private let gradientTabs: [(title: String, symbol: String)] = [
    ("Sunset", "sun.horizon.fill"),
    ("Ocean", "water.waves"),
    ("Lagoon", "leaf.fill"),
    ("Neon", "sparkles")
  ]

  var body: some View {
    TabView {
      ForEach(Array(gradientTabs.enumerated()), id: \.offset) { index, tab in
        Tab(tab.title, systemImage: tab.symbol) {
          AnyDistanceMetalGradientView(page: index)
            .ignoresSafeArea()
            .tag(index)
        }
      }
    }
    .toolbar {
      ToolbarItemGroup {
        Button {
          openURL(URL(string: "https://www.spottedinprod.com/blog/any-distance-goes-open-source")!)
        } label: {
          Label("View article", systemImage: "book.pages")
        }
        Button {
          openURL(URL(string: "https://github.com/851-labs/viewable/blob/main/viewable/AnyDistance/AnyDistanceMetalGradientView.swift")!)
        } label: {
          Label("View source code", systemImage: "curlybraces")
        }
      }
    }
  }
}

#Preview("AnyDistance Gradient") {
  NavigationStack {
    AnyDistanceMetalGradientShowcaseView()
  }
}
