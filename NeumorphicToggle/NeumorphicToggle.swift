import SwiftUI

public struct NeumorphicToggleConfig {
    public let activeColor: Color
    public let inactiveColor: Color
    
    public static let dark = NeumorphicToggleConfig(
        activeColor: .green.opacity(0.9),
        inactiveColor: .gray.opacity(0.4)
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
            let wellDiameter = side * 0.8
            let knobWidth = side * 0.75
            let knobHeight = side * 0.7
            let liftOffset = side * 0.04
            
            ZStack {
                ToggleOuterRing(size: side)
                ToggleInnerWell(isOn: isOn, diameter: wellDiameter)
                
                ToggleKnobButton(
                    isOn: isOn,
                    config: config,
                    width: knobWidth,
                    height: knobHeight
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isOn.toggle()
                    }
                }
                .offset(y: isOn ? -liftOffset : liftOffset)
                
                ToggleInnerShadowMask(
                    isOn: isOn,
                    size: wellDiameter
                )
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct NoPressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

private struct ToggleOuterRing: View {
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color(white: 0.27), Color(white: 0.13)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.8), radius: size * 0.011, y: 1)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .offset(y: 1)
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
                    colors: [
                        isOn ? .black : .white.opacity(0.25),
                        .black,
                        .black
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: diameter * 1.7
                )
            )
            .frame(width: diameter, height: diameter)
            .shadow(
                color: .black.opacity(0.5),
                radius: diameter * 0.047,
                y: diameter * 0.047
            )
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
                    .fill(knobBackgroundGradient)
                
                knobBorderHighlightLayer
                
                VStack {
                    knobTopLabel
                    Spacer()
                    knobBottomLabel
                }
                .padding(.vertical, height * 0.05)
            }
            .frame(width: width, height: height)
        }
        .buttonStyle(NoPressEffectButtonStyle())
    }
    
    private var knobBackgroundGradient: RadialGradient {
        RadialGradient(
            stops: isOn ? activeGradientStops : inactiveGradientStops,
            center: UnitPoint(x: 0.5, y: -0.2),
            startRadius: 0,
            endRadius: height
        )
    }
    
    private var knobBorderHighlightLayer: some View {
        ZStack {
            KnobStrokeLayer(
                isOn: isOn,
                opacity: 0.2,
                activeRange: true,
                width: width
            )
            
            KnobStrokeLayer(
                isOn: isOn,
                opacity: 0.4,
                activeRange: false,
                width: width
            )
        }
        .blur(radius: 0.5)
    }
    
    private var knobTopLabel: some View {
        Text("I")
            .font(.system(size: width * 0.135, weight: .bold))
            .foregroundColor(isOn ? config.activeColor : config.inactiveColor)
            .shadow(color: isOn ? config.activeColor : .clear, radius: 4)
            .shadow(color: isOn ? config.activeColor.opacity(0.8) : .clear, radius: 10)
            .scaleEffect(y: isOn ? 1 : 0.85)
            .opacity(isOn ? 1 : 0.6)
    }
    
    private var knobBottomLabel: some View {
        Text("O")
            .font(.system(size: width * 0.135, weight: .bold))
            .foregroundColor(!isOn ? .white.opacity(0.7) : config.inactiveColor)
            .shadow(color: !isOn ? .white.opacity(0.7) : .clear, radius: 2)
            .shadow(color: !isOn ? .white.opacity(0.4) : .clear, radius: 10)
            .scaleEffect(y: !isOn ? 1 : 0.75)
            .opacity(!isOn ? 1 : 0.6)
    }
    
    private var activeGradientStops: [Gradient.Stop] {
        [
            .init(color: Color(hex: "#181818"), location: 0.00),
            .init(color: Color(hex: "#1f1f1f"), location: 0.22),
            .init(color: Color(hex: "#2a2a2a"), location: 0.50),
            .init(color: Color(hex: "#3a3a3a"), location: 0.80),
            .init(color: Color(hex: "#4a4a4a"), location: 1.00)
        ]
    }
    
    private var inactiveGradientStops: [Gradient.Stop] {
        [
            .init(color: Color(hex: "#131313"), location: 0.00),
            .init(color: Color(hex: "#131313"), location: 0.60),
            .init(color: Color(hex: "#1a1a1a"), location: 0.82),
            .init(color: Color(hex: "#222222"), location: 0.93),
            .init(color: Color(hex: "#2a2a2a"), location: 1.00)
        ]
    }
}

private struct KnobStrokeLayer: View {
    let isOn: Bool
    let opacity: Double
    let activeRange: Bool
    let width: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: width / 2)
            .stroke(
                AngularGradient(
                    gradient: Gradient(
                        colors: [.clear, .white.opacity(opacity), .clear]
                    ),
                    center: .center,
                    startAngle: .degrees(activeRange ? 180 : 0),
                    endAngle: .degrees(activeRange ? 360 : 180)
                ),
                lineWidth: width * 0.0075
            )
            .opacity(isOn != activeRange ? 1 : 0)
    }
}

private struct ToggleInnerShadowMask: View {
    let isOn: Bool
    let size: CGFloat
    
    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: isOn
                    ? [.black, .black, .clear]
                    : [.clear, .black],
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

#Preview {
    @Previewable @State var isOn = true
    
    NeumorphicToggle(isOn: $isOn)
        .frame(width: 320)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.33))
        .ignoresSafeArea()
}
