//
//  ContentView.swift
//  viewable
//
//  Created by Alexandru Turcanu on 6/15/25.
//

import SwiftUI

// MARK: - Sidebar DSL

struct Page: Identifiable, Hashable {
  let id: String
  let title: String
  let subtitle: String?
  let systemImage: String?
  let destination: AnyView?
  let children: [Page]

  init(
    title: String, subtitle: String? = nil, systemImage: String? = nil,
    @ViewBuilder destination: () -> some View
  ) {
    self.id = Self.generateId(from: title)
    self.title = title
    self.subtitle = subtitle
    self.systemImage = systemImage
    // Wrap the destination with navigation title and subtitle
    let baseView = destination()
    if let subtitle = subtitle {
      self.destination = AnyView(
        baseView
          .navigationTitle(title)
          .navigationSubtitle(subtitle)
      )
    } else {
      self.destination = AnyView(
        baseView
          .navigationTitle(title)
      )
    }
    self.children = []
  }

  init(
    title: String, subtitle: String? = nil, systemImage: String? = nil,
    @PageBuilder pages children: () -> [Page]
  ) {
    self.id = Self.generateId(from: title)
    self.title = title
    self.subtitle = subtitle
    self.systemImage = systemImage
    self.destination = nil
    self.children = children()
  }

  private static func generateId(from title: String) -> String {
    // Convert title to camelCase id
    let words = title.components(separatedBy: CharacterSet.alphanumerics.inverted)
      .filter { !$0.isEmpty }

    guard !words.isEmpty else { return title.lowercased() }

    let firstWord = words[0].lowercased()
    let remainingWords = words.dropFirst().map { $0.capitalized }

    return ([firstWord] + remainingWords).joined()
  }

  static func == (lhs: Page, rhs: Page) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  func matches(searchText: String) -> Bool {
    title.localizedCaseInsensitiveContains(searchText)
      || children.contains(where: { $0.matches(searchText: searchText) })
  }

  func flattenedPages() -> [Page] {
    if children.isEmpty {
      return [self]
    }
    return [self] + children.flatMap { $0.flattenedPages() }
  }

  fileprivate init(
    title: String, subtitle: String? = nil, systemImage: String? = nil, children: [Page]
  ) {
    self.id = Self.generateId(from: title)
    self.title = title
    self.subtitle = subtitle
    self.systemImage = systemImage
    self.destination = nil
    self.children = children
  }
}

@resultBuilder
struct PageBuilder {
  static func buildBlock(_ pages: Page...) -> [Page] {
    Array(pages)
  }

  static func buildExpression(_ page: Page) -> Page {
    page
  }

  static func buildArray(_ pages: [Page]) -> [Page] {
    pages
  }
}

struct SidebarSection: Identifiable {
  let id: String
  let title: String
  let pages: [Page]

  init(title: String, @SidebarSectionBuilder pages: () -> [Page]) {
    self.id = title
    self.title = title
    self.pages = pages()
  }

  init(title: String, pages: [Page]) {
    self.id = title
    self.title = title
    self.pages = pages
  }

  func filtered(by searchText: String) -> [Page] {
    guard !searchText.isEmpty else { return pages }
    return pages.compactMap { page in
      if page.matches(searchText: searchText) {
        return page
      }
      let matchingChildren = page.children.filter { $0.matches(searchText: searchText) }
      if !matchingChildren.isEmpty {
        return Page(
          title: page.title, subtitle: page.subtitle, systemImage: page.systemImage,
          children: matchingChildren)
      }
      return nil
    }
  }
}

@resultBuilder
struct SidebarSectionBuilder {
  static func buildBlock(_ pages: Page...) -> [Page] {
    pages
  }
}

@resultBuilder
struct SidebarConfigurationBuilder {
  static func buildBlock(_ sections: SidebarSection...) -> [SidebarSection] {
    sections
  }
}

// MARK: - Sidebar Configuration

extension AppRouter {
  @SidebarConfigurationBuilder
  static var sidebarSections: [SidebarSection] {
    SidebarSection(title: "Components") {
      Page(title: "Button", systemImage: "button.horizontal") {
        ButtonExamplesView()
      }
      Page(title: "Slider", systemImage: "slider.horizontal.3") {
        SliderExamplesView()
      }
      Page(title: "Toggle", systemImage: "switch.2") {
        ToggleExamplesView()
      }
      Page(title: "Stepper", systemImage: "plusminus") {
        StepperExamplesView()
      }
      Page(title: "Color Picker", systemImage: "paintpalette") {
        ColorPickerExamplesView()
      }
    }

    SidebarSection(title: "Views & Modifiers") {
      Page(
        title: "List",
        systemImage: "list.bullet",
        pages: {
          Page(
            title: "listStyle(_:)",
            subtitle: "Sets the style for lists within this view.",
            systemImage: "m.square.fill",
            pages: {
              Page(
                title: "automatic",
                subtitle:
                  "The list style that describes a platform’s default behavior and appearance for a list.",
                systemImage: "p.square.fill"
              ) {
                ListStyleSampleView(kind: .automatic)
              }
              Page(
                title: "plain",
                subtitle:
                  "The list style that describes the behavior and appearance of a plain list.",
                systemImage: "p.square.fill"
              ) {
                ListStyleSampleView(kind: .plain)
              }
              Page(
                title: "grouped",
                subtitle:
                  "The list style that describes the behavior and appearance of a grouped list.",
                systemImage: "p.square.fill"
              ) {
                ListStyleSampleView(kind: .grouped)
              }
              Page(
                title: "inset",
                subtitle:
                  "The list style that describes the behavior and appearance of an inset list.",
                systemImage: "p.square.fill"
              ) {
                ListStyleSampleView(kind: .inset)
              }
              Page(
                title: "insetGrouped",
                subtitle:
                  "The list style that describes the behavior and appearance of an inset grouped list.",
                systemImage: "p.square.fill"
              ) {
                ListStyleSampleView(kind: .insetGrouped)
              }
              Page(
                title: "sidebar",
                subtitle:
                  "The list style that describes the behavior and appearance of a sidebar list.",
                systemImage: "p.square.fill"
              ) {
                ListStyleSampleView(kind: .sidebar)
              }
              Page(
                title: "bordered",
                subtitle:
                  "The list style that describes a platform’s default behavior and appearance for a list.",
                systemImage: "p.square.fill"
              ) {
                ListStyleSampleView(kind: .bordered)
              }
            })
          Page(
            title: "headerProminence(_:)", subtitle: "Sets the header prominence for this view",
            systemImage: "m.square.fill",
            pages: {
              Page(
                title: "standard", subtitle: ".headerProminence(.standard)",
                systemImage: "p.square.fill"
              ) {
                HeaderProminenceSampleView(kind: .standard)
              }
              Page(
                title: "increased", subtitle: ".headerProminence(.increased)",
                systemImage: "p.square.fill"
              ) {
                HeaderProminenceSampleView(kind: .increased)
              }
            })
        })
      Page(
        title: "Form",
        systemImage: "textformat.abc",
        pages: {
          Page(
            title: "formStyle(_:)", subtitle: "Sets the style for forms in a view hierarchy",
            systemImage: "m.square.fill",
            pages: {
              Page(
                title: "automatic", subtitle: ".formStyle(.automatic)",
                systemImage: "p.square.fill"
              ) {
                FormStyleSampleView(kind: .automatic)
              }
              Page(
                title: "grouped", subtitle: ".formStyle(.grouped)",
                systemImage: "p.square.fill"
              ) {
                FormStyleSampleView(kind: .grouped)
              }
              Page(
                title: "columns", subtitle: ".formStyle(.columns)",
                systemImage: "p.square.fill"
              ) {
                FormStyleSampleView(kind: .columns)
              }
            })
        })
      Page(
        title: "Scroll View",
        systemImage: "scroll",
        pages: {
          Page(
            title: "scrollEdgeEffectStyle(_:for:)",
            systemImage: "m.square.fill"
          ) {
            ScrollEdgeEffectView()
          }
        })
      Page(
        title: "Keyboard",
        systemImage: "keyboard",
        pages: {
          Page(title: "keyboardType(_:)", systemImage: "m.square.fill") {
            KeyboardTypeView()
          }
          Page(title: "submitLabel(_:)", systemImage: "m.square.fill") {
            SubmitLabelView()
          }
        })
    }

    SidebarSection(title: "Showcase") {
      Page(
        title: "Any Distance",
        systemImage: "figure.run",
        pages: {
          Page(title: "3-2-1 Go") {
            AnyDistanceCountdownShowcaseView()
          }
          Page(title: "Metal Gradient") {
            AnyDistanceMetalGradientShowcaseView()
          }
          Page(title: "Neon Flickering") {
            AnyDistanceFlickeringImageShowcaseView()
          }
          Page(title: "Confetti Celebration") {
            AnyDistanceConfettiShowcaseView()
          }
        })
      Page(title: "GitHub Graph", systemImage: "chart.bar.fill") {
        GitHubContributionGraphView()
      }
    }
  }
}

// MARK: - Page View

struct PageView: View {
  let page: Page
  @Binding var selectedPage: Page?
  @Binding var expandedPages: Set<String>

  private func isExpanded(_ pageId: String) -> Binding<Bool> {
    Binding(
      get: { expandedPages.contains(pageId) },
      set: { isExpanded in
        if isExpanded {
          expandedPages.insert(pageId)
        } else {
          expandedPages.remove(pageId)
        }
      })
  }

  @ViewBuilder
  private func styledLabel(title: String, systemImage: String) -> some View {
    if systemImage == "m.square.fill" {
      Label {
        Text(title)
      } icon: {
        Image(systemName: systemImage)
          .font(.title2)
          .foregroundStyle(.blue)
          .symbolColorRenderingMode(.gradient)
      }
    } else if systemImage == "p.square.fill" {
      Label {
        Text(title)
      } icon: {
        Image(systemName: systemImage)
          .font(.title2)
          .foregroundStyle(.cyan)
          .symbolColorRenderingMode(.gradient)
      }
    } else {
      Label {
        Text(title)
      } icon: {
        Image(systemName: systemImage)
          .foregroundStyle(.secondary)
          .symbolColorRenderingMode(.gradient)
      }
    }
  }

  var body: some View {
    if page.children.isEmpty {
      NavigationLink(value: page) {
        if let systemImage = page.systemImage {
          styledLabel(title: page.title, systemImage: systemImage)
        } else {
          Text(page.title)
        }
      }
    } else {
      DisclosureGroup(isExpanded: isExpanded(page.id)) {
        ForEach(page.children) { child in
          PageView(page: child, selectedPage: $selectedPage, expandedPages: $expandedPages)
        }
      } label: {
        if let systemImage = page.systemImage {
          styledLabel(title: page.title, systemImage: systemImage)
        } else {
          Label(page.title, systemImage: "folder.fill")
        }
      }
    }
  }
}

// MARK: - Content View

struct AppRouter: View {
  @State private var selectedPage: Page?
  @State private var searchText: String = ""
  @State private var expandedPages: Set<String> = Set()

  private var filteredSections: [SidebarSection] {
    Self.sidebarSections.compactMap { section in
      let filtered = section.filtered(by: searchText)
      return filtered.isEmpty ? nil : SidebarSection(title: section.title, pages: filtered)
    }
  }

  var body: some View {
    NavigationSplitView {
      List(selection: $selectedPage) {
        ForEach(filteredSections) { section in
          Section(section.title) {
            ForEach(section.pages) { page in
              PageView(page: page, selectedPage: $selectedPage, expandedPages: $expandedPages)
            }
          }
        }
      }
      .navigationTitle("Viewable")
      .searchable(text: $searchText, placement: .sidebar, prompt: "Search examples")
      .overlay {
        if filteredSections.isEmpty {
          ContentUnavailableView.search
        }
      }
    } detail: {
      if let selectedPage, let destination = selectedPage.destination {
        NavigationStack {
          destination
        }
      } else {
        ContentUnavailableView(
          "Select an item",
          systemImage: "sidebar.left",
          description: Text("Choose a component from the sidebar"))
      }
    }
  }
}

#Preview {
  AppRouter()
}
