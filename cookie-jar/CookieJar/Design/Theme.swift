import SwiftUI
import UIKit

/// Design tokens. Light mode only in V1.
enum Theme {
    // Surfaces
    static let cream = Color(hex: 0xF3EBDD)
    static let card = Color(hex: 0xF9F4EA)
    static let cardOn = Color(hex: 0xEDE2CC)
    static let border = Color(hex: 0xD9C7A6)
    static let tile = Color(hex: 0xE5D6BC)
    static let jarGlass = Color(hex: 0xFBF6EC)

    // Ink
    static let ink = Color(hex: 0x2B2119)
    static let inkSecondary = Color(hex: 0x6F6257)
    static let inkTertiary = Color(hex: 0x9A8D80)

    // Accents
    static let terracotta = Color(hex: 0xC0533D)
    static let terracottaDark = Color(hex: 0x8F3A2A)
    static let amber = Color(hex: 0xD99A3E)
    static let amberDark = Color(hex: 0xA9701F)
    static let chip = Color(hex: 0x4A2E17)

    static let cardRadius: CGFloat = 20

    // MARK: Type

    enum Fonts {
        static let displayName = "Fraunces-Black"
        static let serifBoldName = "Fraunces-Bold"

        static var bundledAvailable: Bool {
            UIFont(name: displayName, size: 12) != nil && UIFont(name: serifBoldName, size: 12) != nil
        }

        static func display(_ size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
            bundledAvailable
                ? .custom(displayName, size: size, relativeTo: style)
                : .system(style, design: .serif, weight: .black)
        }

        static func serifBold(_ size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
            bundledAvailable
                ? .custom(serifBoldName, size: size, relativeTo: style)
                : .system(style, design: .serif, weight: .bold)
        }
    }

    /// "Make today count."
    static let hero = Fonts.display(44, relativeTo: .largeTitle)
    /// "How did it go?", "Your rhythm"
    static let headline = Fonts.display(32, relativeTo: .title)
    /// Onboarding and settings titles.
    static let titleSerif = Fonts.display(28, relativeTo: .title)
    static let statNumeral = Fonts.display(30, relativeTo: .title)
    static let tileLetter = Fonts.serifBold(22, relativeTo: .title2)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
