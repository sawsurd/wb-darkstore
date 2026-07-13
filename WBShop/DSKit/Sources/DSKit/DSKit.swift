import Foundation
import SwiftUI

@available(iOS 13.0, *)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

@available(iOS 13.0, *)
extension LinearGradient {
    static let figmaPurplePink = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "ED3CCA"), location: 0.0049),
            .init(color: Color(hex: "DF34D2"), location: 0.1488),
            .init(color: Color(hex: "D02BD9"), location: 0.2927),
            .init(color: Color(hex: "BF22E1"), location: 0.4314),
            .init(color: Color(hex: "AE1AE8"), location: 0.5702),
            .init(color: Color(hex: "9A10F0"), location: 0.7089),
            .init(color: Color(hex: "8306F7"), location: 0.8476),
            .init(color: Color(hex: "6600FF"), location: 0.9915)
        ]),
        startPoint: UnitPoint(x: 0.004, y: 0.437),
        endPoint: UnitPoint(x: 0.996, y: 0.563)
    )

    static let figmaLightPinkPurple = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "FEF1FB"), location: 0.0049),
            .init(color: Color(hex: "FDF1FC"), location: 0.1488),
            .init(color: Color(hex: "FCF0FC"), location: 0.2927),
            .init(color: Color(hex: "FBF0FD"), location: 0.4314),
            .init(color: Color(hex: "F9EFFD"), location: 0.5702),
            .init(color: Color(hex: "F8EEFE"), location: 0.7089),
            .init(color: Color(hex: "F6EEFE"), location: 0.8476),
            .init(color: Color(hex: "F4EDFF"), location: 0.9915)
        ]),
        startPoint: UnitPoint(x: 0.004, y: 0.437),
        endPoint: UnitPoint(x: 0.996, y: 0.563)
    )
}

@available(iOS 15.0, *)
public enum DSButtonStyle {
    case primary, secondary, destructive, gradient, lightPinkPurple

    var background: AnyShapeStyle {
        switch self {
        case .primary: return AnyShapeStyle(DSColors.primary)
        case .secondary: return AnyShapeStyle(DSColors.secondary)
        case .destructive: return AnyShapeStyle(Color.red)
        case .gradient: return AnyShapeStyle(LinearGradient.figmaPurplePink)
        case .lightPinkPurple: return AnyShapeStyle(LinearGradient.figmaLightPinkPurple)
        }
    }

    var buttonTextColor: Color {
        switch self {
        case .primary: return .white
        case .secondary: return .black
        case .destructive: return .white
        case .gradient: return .white
        case .lightPinkPurple: return .black
        }
    }
}

@available(iOS 16.0, *)
public enum DSButtonKind {
    case addToCart
    case fullWidthAction

    var showsIcon: Bool {
        switch self {
        case .addToCart: return true
        case .fullWidthAction: return false
        }
    }

    var isFullWidth: Bool {
        switch self {
        case .addToCart: return false
        case .fullWidthAction: return true
        }
    }

    var font: Font {
        switch self {
        case .addToCart: return DSTypography.buttonPriceText
        case .fullWidthAction: return DSTypography.body
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .addToCart: return 12
        case .fullWidthAction: return 20
        }
    }

    var topPadding: CGFloat {
        switch self {
        case .addToCart: return 6
        case .fullWidthAction: return 14
        }
    }

    var bottomPadding: CGFloat {
        switch self {
        case .addToCart: return 9
        case .fullWidthAction: return 14
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .addToCart: return 6
        case .fullWidthAction: return 12
        }
    }
}

@available(iOS 16.0, *)
public struct DSButton: View {
    public let title: String
    public let style: DSButtonStyle
    public let kind: DSButtonKind
    public let action: () -> Void

    public init(title: String, style: DSButtonStyle, kind: DSButtonKind = .fullWidthAction, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.kind = kind
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(kind.font)
                    .foregroundColor(style.buttonTextColor)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                if kind.showsIcon {
                    Image("plus")
                }
            }
            .frame(maxWidth: kind.isFullWidth ? .infinity : nil)
            .padding(.horizontal, kind.horizontalPadding)
            .padding(.top, kind.topPadding)
            .padding(.bottom, kind.bottomPadding)
            .background(style.background)
            .cornerRadius(kind.cornerRadius)
        }
    }
}

@available(iOS 13.0, *)
public struct DSTextField: View {
    private let placeholder: String
    @Binding private var text: String

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        TextField(placeholder, text: $text)
            .padding(.vertical, 8)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.5)),
                alignment: .bottom
            )
    }
}

@available(iOS 13.0, *)
public struct DSCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}

@available(iOS 13.0, *)
public struct DSColors {
    public static let primary = Color.purple
    public static let secondary = Color.gray
    public static let background = Color(.systemBackground)
}

@available(iOS 16.0, *)
public struct DSTypography {
    public static let title = Font.system(size: 24, weight: .bold)
    public static let body = Font.system(size: 16)
    public static let caption = Font.system(size: 12)
    public static let buttonPriceText = Font.system(size: 14, weight: .semibold)
    public static let price = Font.system(size: 32, weight: .regular)
    public static let name = Font.system(size: 26, weight: .regular)
    
}
