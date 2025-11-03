import QuartzCore
import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

// MARK: - Confetti View Style

enum ConfettiViewStyle: Equatable {
  case large
  case small
}

// MARK: - Platform-specific Implementation

#if canImport(UIKit) || canImport(AppKit)

  // MARK: - Native Confetti View with CAEmitterLayer

  #if canImport(UIKit)
    typealias PlatformView = UIView
    typealias PlatformColor = UIColor
    typealias PlatformViewRepresentable = UIViewRepresentable
  #else
    typealias PlatformView = NSView
    typealias PlatformColor = NSColor
    typealias PlatformViewRepresentable = NSViewRepresentable
  #endif

  class NativeConfettiView: PlatformView {
    var colors = [PlatformColor]()
    var intensity: Float = 0.8
    var style: ConfettiViewStyle = .large

    private(set) var emitter: CAEmitterLayer?
    private var active = false
    private var confettiImage: CGImage?

    override init(frame: CGRect) {
      super.init(frame: frame)
      setup()
    }

    required init?(coder: NSCoder) {
      super.init(coder: coder)
      setup()
    }

    private func setup() {
      #if canImport(AppKit)
        wantsLayer = true
      #endif
      loadConfettiImage()
    }

    private func loadConfettiImage() {
      #if canImport(UIKit)
        if let uiImage = UIImage(named: "confetti") {
          confettiImage = uiImage.cgImage
        }
      #else
        if let nsImage = NSImage(named: "confetti") {
          var imageRect = CGRect(x: 0, y: 0, width: nsImage.size.width, height: nsImage.size.height)
          confettiImage = nsImage.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        }
      #endif
    }

    func startConfetti(beginAtTimeZero: Bool = true) {
      emitter?.removeFromSuperlayer()
      emitter = CAEmitterLayer()

      if beginAtTimeZero {
        emitter?.beginTime = CACurrentMediaTime()
      }

      #if canImport(UIKit)
        // iOS: emit from top, fall down
        emitter?.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: -10)
        let velocityMultiplier: CGFloat = 1.0
      #else
        // macOS: emit from top, fall down (inverted coordinate system)
        emitter?.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: frame.size.height + 10)
        let velocityMultiplier: CGFloat = -1.0
      #endif

      emitter?.emitterShape = .line
      emitter?.emitterSize = CGSize(width: frame.size.width, height: 1)

      var cells = [CAEmitterCell]()
      for color in colors {
        cells.append(confettiCell(color: color, velocityMultiplier: velocityMultiplier))
      }

      emitter?.emitterCells = cells

      switch style {
      case .large:
        emitter?.birthRate = 4
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          self.emitter?.birthRate = 0.6
        }
      case .small:
        emitter?.birthRate = 0.35
      }

      #if canImport(UIKit)
        layer.addSublayer(emitter!)
      #else
        layer?.addSublayer(emitter!)
      #endif
      active = true
    }

    func stopConfetti() {
      emitter?.birthRate = 0
      active = false
    }

    #if canImport(UIKit)
      override func layoutSubviews() {
        super.layoutSubviews()
        emitter?.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: -10)
        emitter?.emitterSize = CGSize(width: frame.size.width, height: 1)
      }
    #else
      override func layout() {
        super.layout()
        emitter?.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: frame.size.height + 10)
        emitter?.emitterSize = CGSize(width: frame.size.width, height: 1)
      }
    #endif

    private func confettiCell(color: PlatformColor, velocityMultiplier: CGFloat) -> CAEmitterCell {
      let confetti = CAEmitterCell()
      confetti.birthRate = 12.0 * intensity
      confetti.lifetime = 14.0 * intensity
      confetti.lifetimeRange = 0
      confetti.color = color.cgColor
      confetti.velocity = CGFloat(350.0 * intensity) * velocityMultiplier
      confetti.velocityRange = CGFloat(80.0 * intensity)
      confetti.emissionLongitude = CGFloat(Double.pi)
      confetti.emissionRange = CGFloat(Double.pi)
      confetti.spin = CGFloat(3.5 * intensity)
      confetti.spinRange = CGFloat(4.0 * intensity)
      confetti.scaleRange = CGFloat(intensity)
      confetti.scaleSpeed = CGFloat(-0.1 * intensity)
      confetti.contents = confettiImage
      confetti.contentsScale = 1.5
      confetti.setValue("plane", forKey: "particleType")
      confetti.setValue(Double.pi, forKey: "orientationRange")
      confetti.setValue(Double.pi / 2, forKey: "orientationLongitude")
      confetti.setValue(Double.pi / 2, forKey: "orientationLatitude")

      if style == .small {
        confetti.contentsScale = 3.0
        confetti.velocity = CGFloat(70.0 * intensity) * velocityMultiplier
        confetti.velocityRange = CGFloat(20.0 * intensity)
      }

      return confetti
    }

    func isActive() -> Bool {
      return active
    }
  }

  // MARK: - SwiftUI Wrapper for Native View

  struct ConfettiViewRepresentable: PlatformViewRepresentable {
    let isActive: Bool
    let intensity: Float
    let style: ConfettiViewStyle
    let colors: [PlatformColor]

    #if canImport(UIKit)
      func makeUIView(context: Context) -> NativeConfettiView {
        let confettiView = NativeConfettiView()
        confettiView.backgroundColor = .clear
        confettiView.intensity = intensity
        confettiView.style = style
        confettiView.colors = colors
        return confettiView
      }

      func updateUIView(_ uiView: NativeConfettiView, context: Context) {
        // This will only be called when isActive changes since other property
        // changes trigger a view identity change and full remount
        if isActive, !uiView.isActive() {
          uiView.startConfetti()
        } else if !isActive, uiView.isActive() {
          uiView.stopConfetti()
        }
      }
    #else
      func makeNSView(context: Context) -> NativeConfettiView {
        let confettiView = NativeConfettiView()
        confettiView.intensity = intensity
        confettiView.style = style
        confettiView.colors = colors
        return confettiView
      }

      func updateNSView(_ nsView: NativeConfettiView, context: Context) {
        // This will only be called when isActive changes since other property
        // changes trigger a view identity change and full remount
        if isActive, !nsView.isActive() {
          nsView.startConfetti()
        } else if !isActive, nsView.isActive() {
          nsView.stopConfetti()
        }
      }
    #endif
  }

#endif

// MARK: - Color Presets

enum ColorPreset: String, CaseIterable {
  case traditional = "Traditional"
  case neon = "Neon"
  case ocean = "Ocean"
  case sunset = "Sunset"
  case custom = "Custom"

  var colors: [Color] {
    switch self {
    case .traditional:
      return [
        .red,
        .yellow,
        .green,
        .blue,
        .purple,
        .orange,
      ]
    case .neon:
      return [
        Color(red: 255 / 255, green: 50 / 255, blue: 134 / 255),  // Pink
        Color(red: 236 / 255, green: 18 / 255, blue: 60 / 255),  // Red
        Color(red: 178 / 255, green: 254 / 255, blue: 0 / 255),  // Green
        Color(red: 0 / 255, green: 248 / 255, blue: 209 / 255),  // Cyan
        Color(red: 0 / 255, green: 186 / 255, blue: 255 / 255),  // Blue
      ]
    case .ocean:
      return [
        Color(red: 183 / 255, green: 246 / 255, blue: 254 / 255),
        Color(red: 50 / 255, green: 160 / 255, blue: 251 / 255),
        Color(red: 3 / 255, green: 79 / 255, blue: 231 / 255),
        Color(red: 1 / 255, green: 49 / 255, blue: 161 / 255),
        Color(red: 3 / 255, green: 12 / 255, blue: 47 / 255),
      ]
    case .sunset:
      return [
        Color(red: 252 / 255, green: 60 / 255, blue: 0 / 255),
        Color(red: 253 / 255, green: 0 / 255, blue: 12 / 255),
        Color(red: 255 / 255, green: 153 / 255, blue: 51 / 255),
        Color(red: 255 / 255, green: 204 / 255, blue: 0 / 255),
        Color(red: 255 / 255, green: 15 / 255, blue: 8 / 255),
      ]
    case .custom:
      return []  // Will be managed separately
    }
  }
}

// MARK: - Showcase View

struct AnyDistanceConfettiShowcaseView: View {
  @Environment(\.openURL) private var openURL

  @State private var isActive = false
  @State private var intensity: Float = 0.8
  @State private var style: ConfettiViewStyle = .large
  @State private var colorPreset: ColorPreset = .traditional
  @State private var customColors: [Color] = []
  @State private var colors: [Color] = ColorPreset.traditional.colors
  @State private var isInspectorPresented = true

  // Create a stable string representation for view identity
  private var viewId: String {
    let colorId =
      colorPreset == .custom ? "custom-\(colors.description.hashValue)" : colorPreset.rawValue
    return "\(intensity)-\(style)-\(colorId)"
  }

  var body: some View {
    ZStack {
      // Background
      Color.clear
        .ignoresSafeArea()

      // Confetti
      #if canImport(UIKit) || canImport(AppKit)
        ConfettiViewRepresentable(
          isActive: isActive,
          intensity: intensity,
          style: style,
          colors: colors.map { PlatformColor($0) }
        )
        .allowsHitTesting(false)
        .ignoresSafeArea()
        // Force remount when properties change (except isActive)
        .id(viewId)
      #else
        UnavailableFeatureView(feature: "Confetti (CAEmitterLayer)")
          .ignoresSafeArea()
      #endif
    }
    .onAppear {
      // Auto-start confetti after a delay
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        isActive = true
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
          openURL(
            URL(
              string:
                "https://github.com/851-labs/viewable/blob/main/viewable/Examples/Showcase/AnyDistance/AnyDistanceConfettiView.swift"
            )!)
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
      #if canImport(UIKit) || canImport(AppKit)
        Form {
          Section("Controls") {
            Toggle("Active", isOn: $isActive)
              .toggleStyle(.switch)
          }

          Section("Style") {
            Picker("Size", selection: $style) {
              Text("Large").tag(ConfettiViewStyle.large)
              Text("Small").tag(ConfettiViewStyle.small)
            }
            .pickerStyle(.segmented)

            Slider(value: $intensity, in: 0.1...1.0) {
              Text("Intensity: \(String(format: "%.1f", intensity))")
            }
          }

          Section("Colors") {
            Picker("Preset", selection: $colorPreset) {
              ForEach(ColorPreset.allCases, id: \.self) { preset in
                Text(preset.rawValue).tag(preset)
              }
            }
            .onChange(of: colorPreset) { _, newValue in
              if newValue != .custom {
                colors = newValue.colors
              }
            }

            if colorPreset == .custom {
              VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<customColors.count, id: \.self) { index in
                  HStack {
                    ColorPicker("Color \(index + 1)", selection: $customColors[index])
                    Button {
                      customColors.remove(at: index)
                      updateCustomColors()
                    } label: {
                      Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                  }
                }

                Button {
                  customColors.append(Color.random)
                  updateCustomColors()
                } label: {
                  Label("Add Color", systemImage: "plus.circle.fill")
                }
                .disabled(customColors.count >= 10)
              }
            }

            // Color preview
            HStack(spacing: 4) {
              ForEach(0..<colors.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                  .fill(colors[index])
                  .frame(height: 30)
              }
            }
            .padding(.top, 4)
          }
        }
        .inspectorColumnWidth(min: 280, ideal: 320)
      #else
        Form {
          Text("Confetti controls are not available on this platform")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      #endif
    }
    .onAppear {
      // Initialize custom colors from current colors
      customColors = colors
    }
  }

  private func updateCustomColors() {
    colors = customColors
  }
}

// MARK: - Helper Extensions

extension Color {
  fileprivate static var random: Color {
    Color(
      red: Double.random(in: 0...1),
      green: Double.random(in: 0...1),
      blue: Double.random(in: 0...1)
    )
  }
}

#Preview("AnyDistance Confetti") {
  NavigationStack { AnyDistanceConfettiShowcaseView() }
}
