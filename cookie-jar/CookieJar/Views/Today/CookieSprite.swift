import SwiftUI

/// Round amber cookie with a darker outline and dark chip dots.
struct CookieSprite: View {
    var diameter: CGFloat = 28

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.amber)
            Circle()
                .strokeBorder(Theme.amberDark, lineWidth: max(1.5, diameter * 0.07))
            chip(size: 0.16, x: -0.24, y: -0.18)
            chip(size: 0.15, x: 0.2, y: 0.1)
            chip(size: 0.11, x: -0.06, y: 0.3)
        }
        .frame(width: diameter, height: diameter)
        .accessibilityHidden(true)
    }

    private func chip(size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(Theme.chip)
            .frame(width: diameter * size, height: diameter * size)
            .offset(x: diameter * x, y: diameter * y)
    }
}

#Preview {
    HStack(spacing: 12) {
        CookieSprite(diameter: 20)
        CookieSprite(diameter: 32)
        CookieSprite(diameter: 56)
    }
    .padding()
    .background(Theme.cream)
}
