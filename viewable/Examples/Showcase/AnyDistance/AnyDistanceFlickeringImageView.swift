import SwiftUI

// MARK: - Flickering Image View

struct AnyDistanceFlickeringImage: View {
  let imageName: String
  
  @State private var opacity: Double = 0
  @State private var isGlowing = false
  @State private var flickerTimer: Timer?
  
  private let numFlickers: Int = 8
  @State private var flickerCount: Int = 0
  
  var body: some View {
    Image(imageName)
      .resizable()
      .scaledToFit()
      .opacity(opacity)
      .onAppear {
        startAnimation()
      }
      .onDisappear {
        flickerTimer?.invalidate()
      }
  }
  
  private func startAnimation() {
    startGlowing()
    continueFlickering()
  }
  
  private func startGlowing() {
    let duration = Double.random(in: 0.4...0.8)
    let newOpacity: Double = opacity < 1.0 ? 1.0 : 0.8
    
    withAnimation(.easeInOut(duration: duration)) {
      opacity = newOpacity
      isGlowing = true
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
      startGlowing()
    }
  }
  
  private func continueFlickering() {
    let currentOpacity = opacity
    opacity = currentOpacity < 1.0 ? 1.0 : 0.2
    
    let delay: TimeInterval = opacity < 1.0 ? .random(in: 0.01...0.03) : .random(in: 0.03...0.4)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      continueFlickering()
    }
  }
}

// MARK: - Showcase View

struct AnyDistanceFlickeringImageShowcaseView: View {
  @Environment(\.openURL) private var openURL
  
  var body: some View {
    VStack(spacing: 32) {
      AnyDistanceFlickeringImage(imageName: "madewithsoul")
        .frame(width: 250, height: 250)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .preferredColorScheme(.dark)
    .toolbar {
      ToolbarItemGroup {
        Button {
          openURL(URL(string: "https://www.spottedinprod.com/blog/any-distance-goes-open-source")!)
        } label: {
          Label("View article", systemImage: "book.pages")
        }
        Button {
          openURL(URL(string: "https://github.com/851-labs/viewable/blob/main/viewable/AnyDistance/AnyDistanceFlickeringImageView.swift")!)
        } label: {
          Label("View source code", systemImage: "curlybraces")
        }
      }
    }
  }
}

#Preview("AnyDistance Flickering Image") {
  NavigationStack { AnyDistanceFlickeringImageShowcaseView() }
}
