import SwiftUI

public struct NeumorphicToggleConfig {
    public let activeColor: Color
    public let inactiveColor: Color
    
    public static let dark = NeumorphicToggleConfig(
        activeColor: Color(red: 0, green: 0.9, blue: 0, opacity: 0.9),
        inactiveColor: Color(white: 0.4)
    )
}

public struct NeumorphicToggle: View {
    @Binding private var isOn: Bool
    private let config: NeumorphicToggleConfig
    
    public init(
        isOn: Binding<Bool>,
        config: NeumorphicToggleConfig = .dark
    ) {
        self._isOn = isOn
        self.config = config
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            
            ZStack {
                ZStack {
                    ToggleOuterRing(size: side)
                    ToggleInnerWell(isOn: isOn, diameter: side * 0.8)
                    ToggleKnobButton(
                        isOn: isOn,
                        config: config,
                        width: side * 0.75,
                        height: side * 0.7
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isOn.toggle()
                        }
                    }
                    .offset(y: isOn ? -side * 0.04 : side * 0.04)
                    ToggleInnerShadowMask(isOn: isOn, size: side * 0.8)
                }
                .drawingGroup()
            }
            .shadow(color: .black.opacity(0.8), radius: side * 0.012, y: side * 0.003)
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct ToggleOuterRing: View {
    let size: CGFloat
    private static let grad = LinearGradient(
        colors: [Color(white: 0.27), Color(white: 0.13)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        Circle()
            .fill(Self.grad)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: size * 0.003)
                    .offset(y: size * 0.003)
                    .mask(Circle())
            )
    }
}

private struct ToggleInnerWell: View {
    let isOn: Bool
    let diameter: CGFloat
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: isOn
                    ? [.black, .black, .black]
                    : [.white.opacity(0.25), .black, .black],
                    center: .top,
                    startRadius: 0,
                    endRadius: diameter * 1.7
                )
            )
            .frame(width: diameter, height: diameter)
            .shadow(color: .black.opacity(0.5), radius: diameter * 0.05, y: diameter * 0.05)
    }
}

private struct ToggleKnobButton: View {
    let isOn: Bool
    let config: NeumorphicToggleConfig
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: width / 2)
                    .fill(
                        RadialGradient(
                            stops: isOn ? GradientStops.active : GradientStops.inactive,
                            center: UnitPoint(x: 0.5, y: -0.2),
                            startRadius: 0,
                            endRadius: height
                        )
                    )
                KnobStrokeLayer(isOn: isOn, width: width)
                VStack {
                    knobLabel("I", isActive: isOn, activeColor: config.activeColor)
                    Spacer()
                    knobLabel("O", isActive: !isOn, activeColor: .white.opacity(0.7))
                }
                .padding(.vertical, height * 0.05)
            }
            .frame(width: width, height: height)
        }
        .buttonStyle(NoPressEffectButtonStyle())
    }
    
    private func knobLabel(
        _ text: String,
        isActive: Bool,
        activeColor: Color
    ) -> some View {
        Text(text)
            .font(.system(size: width * 0.135, weight: .bold))
            .foregroundColor(isActive ? activeColor : config.inactiveColor)
            .shadow(color: isActive ? activeColor : .clear, radius: 4)
            .shadow(color: isActive ? activeColor.opacity(0.8) : .clear, radius: 10)
            .scaleEffect(y: isActive ? 1 : 0.85)
            .opacity(isActive ? 1 : 0.6)
    }
}

private struct KnobStrokeLayer: View {
    let isOn: Bool
    let width: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: width / 2)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.clear, .white.opacity(0.2), .clear]),
                        center: .center,
                        startAngle: .degrees(180),
                        endAngle: .degrees(360)
                    ),
                    lineWidth: width * 0.0075
                )
                .opacity(isOn ? 0 : 1)
            
            RoundedRectangle(cornerRadius: width / 2)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.clear, .white.opacity(0.4), .clear]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(180)
                    ),
                    lineWidth: width * 0.0075
                )
                .opacity(isOn ? 1 : 0)
        }
        .blur(radius: 0.5)
    }
}

private struct ToggleInnerShadowMask: View {
    let isOn: Bool
    let size: CGFloat
    
    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: isOn ? [.black, .black, .clear] : [.clear, .black],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: size * 0.1
            )
            .blur(radius: size * 0.015)
            .offset(y: size * 0.01)
            .mask(Circle())
            .frame(width: size, height: size)
    }
}

private struct NoPressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

private struct GradientStops {
    static let active: [Gradient.Stop] = [
        .init(color: Color(white: 0.09), location: 0.00),
        .init(color: Color(white: 0.12), location: 0.22),
        .init(color: Color(white: 0.16), location: 0.50),
        .init(color: Color(white: 0.23), location: 0.80),
        .init(color: Color(white: 0.29), location: 1.00)
    ]
    
    static let inactive: [Gradient.Stop] = [
        .init(color: Color(white: 0.07), location: 0.00),
        .init(color: Color(white: 0.07), location: 0.60),
        .init(color: Color(white: 0.10), location: 0.82),
        .init(color: Color(white: 0.13), location: 0.93),
        .init(color: Color(white: 0.16), location: 1.00)
    ]
}

#Preview {
    @Previewable @State var isOn = true
    
    NeumorphicToggle(isOn: $isOn)
        .frame(width: 320)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.33))
        .ignoresSafeArea()
}
