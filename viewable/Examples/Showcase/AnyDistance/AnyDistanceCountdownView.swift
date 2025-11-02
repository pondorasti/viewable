import SwiftUI

// MARK: - AnyDistanceCountdownView

/// Prefixed Any Distance-style 3-2-1-Go countdown.
struct AnyDistanceCountdownView: View {
  @State private var animationStep: CGFloat = 4 // 4→3→2→1→0 (GO)
  @State private var animationTimer: Timer?
  @State private var isFinished = false
  @State private var hapticTrigger = 0

  @Binding var skip: Bool
  var finishedAction: () -> Void

  private func xOffset() -> CGFloat {
    let c = max(min(animationStep, 3), 0)
    return c > 0 ? 60 * (c - 1) - 10 : -90
  }

  private func startTimer() {
    animationTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { _ in
      Task { @MainActor in
        guard animationStep >= 0 else { return }

        if animationStep == 0 {
          withAnimation(.easeIn(duration: 0.15)) { isFinished = true }
          finishedAction()
          animationTimer?.invalidate()
        }

        withAnimation(.easeInOut(duration: animationStep == 4 ? 0.3 : 0.4)) {
          animationStep -= 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          hapticTrigger += 1
        }
      }
    }
  }

  var body: some View {
    VStack {
      ZStack {
        Color.clear
          .background(.ultraThinMaterial)
          .environment(\.colorScheme, .dark)

        HStack(spacing: 0) {
          Text("3").font(.system(size: 89, weight: .semibold)).frame(width: 60)
            .opacity(animationStep >= 3 ? 1 : 0.6)
            .scaleEffect(animationStep >= 3 ? 1 : 0.6)
          Text("2").font(.system(size: 89, weight: .semibold)).frame(width: 60)
            .opacity(animationStep == 2 ? 1 : 0.6)
            .scaleEffect(animationStep == 2 ? 1 : 0.6)
          Text("1").font(.system(size: 89, weight: .semibold)).frame(width: 60)
            .opacity(animationStep == 1 ? 1 : 0.6)
            .scaleEffect(animationStep == 1 ? 1 : 0.6)
          Text("GO").font(.system(size: 65, weight: .bold)).frame(width: 100)
            .opacity(animationStep == 0 ? 1 : 0.6)
            .scaleEffect(animationStep == 0 ? 1 : 0.6)
        }
        .foregroundStyle(Color.white)
        .offset(x: xOffset())
      }
      .mask {
        RoundedRectangle(cornerRadius: 65).frame(width: 130, height: 200)
      }
      .opacity(isFinished ? 0 : 1)
      .scaleEffect(isFinished ? 1.2 : 1)
      .blur(radius: isFinished ? 6 : 0)
      .opacity(animationStep < 4 ? 1 : 0)
      .scaleEffect(animationStep < 4 ? 1 : 0.8)
      .sensoryFeedback(.impact(weight: .heavy, intensity: 0.8), trigger: hapticTrigger) { oldValue, newValue in
        let step = Int(animationStep)
        return newValue != oldValue && step > 0 && step < 4
      }
      .sensoryFeedback(.success, trigger: hapticTrigger) { oldValue, newValue in
        newValue != oldValue && Int(animationStep) == 0
      }
    }
    .onChange(of: skip) { _, newValue in
      if newValue {
        animationTimer?.invalidate()
        withAnimation(.easeIn(duration: 0.15)) { isFinished = true }
        finishedAction()
      }
    }
    .onAppear {
      guard animationStep == 4 else { return }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { startTimer() }
    }
  }
}

// MARK: - Showcase container

struct AnyDistanceCountdownShowcaseView: View {
  @Environment(\.openURL) private var openURL

  @State private var skip = false
  @State private var done = false
  @State private var resetTrigger = 0
  @State private var isInspectorPresented = true

  var body: some View {
    VStack(spacing: 24) {
      AnyDistanceCountdownView(skip: $skip) { done = true }
        .id(resetTrigger)

      if done {
        Label("Start!", systemImage: "checkmark.circle.fill")
          .font(.title.bold())
          .foregroundStyle(.green)
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .padding(.bottom)
      }
    }
    .padding()
    .animation(.easeInOut, value: done)
    .toolbar {
      ToolbarItemGroup {
        Button {
          openURL(URL(string: "https://www.spottedinprod.com/blog/any-distance-goes-open-source")!)
        } label: {
          Label("View article", systemImage: "book.pages")
        }
        Button {
          openURL(URL(string: "https://github.com/851-labs/viewable/blob/main/viewable/AnyDistance/AnyDistanceCountdownView.swift")!)
        } label: {
          Label("View source code", systemImage: "curlybraces")
        }
      }
      ToolbarSpacer()
      ToolbarItem {
        Button {
          isInspectorPresented.toggle()
        } label: {
          Label("Controls", systemImage: "info.circle")
        }
      }
    }
    .inspector(isPresented: $isInspectorPresented) {
      Form {
        Section("Controls") {
          Button {
            skip = true
          } label: {
            Label("Skip", systemImage: "forward.fill")
          }
          .disabled(done)

          Button {
            skip = false
            done = false
            resetTrigger += 1
          } label: {
            Label("Reset", systemImage: "arrow.counterclockwise")
          }
        }
      }
    }
  }
}

#Preview("AnyDistance Countdown") {
  NavigationStack { AnyDistanceCountdownShowcaseView() }
}
