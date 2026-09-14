import SwiftUI

/// The phases of the cookie drop. The animator starts and ends at `.settled`,
/// so cookies that were never dropped (or were restored on launch) sit still.
enum DropPhase: CaseIterable, Equatable {
    case settled
    case above
    case landed
    case squash

    var scale: CGSize {
        switch self {
        case .squash: return CGSize(width: 1.16, height: 0.8)
        default: return CGSize(width: 1, height: 1)
        }
    }

    /// Animation used when transitioning *into* this phase.
    var animation: Animation? {
        switch self {
        case .settled: return .spring(response: 0.28, dampingFraction: 0.5)
        case .above: return nil
        case .landed: return .spring(response: 0.45, dampingFraction: 0.58)
        case .squash: return .easeOut(duration: 0.08)
        }
    }
}

/// Cream jar with a terracotta ridged lid, holding a capped pile of cookies.
///
/// - `cookieCount`: total cookies earned; up to `capacity` are drawn.
/// - `dropTrigger`: increment to play the drop animation for the newest cookie.
struct JarView: View {
    static let capacity = 12

    let cookieCount: Int
    let dropTrigger: Int

    /// Per-slot trigger values, so only the slot that just filled animates.
    @State private var slotTriggers: [Int: Int] = [:]

    private var visibleCount: Int { min(max(cookieCount, 0), JarView.capacity) }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let lidHeight = h * 0.13
            let bodyRect = CGRect(x: 0, y: lidHeight * 0.7, width: w, height: h - lidHeight * 0.7)
            let inner = bodyRect.insetBy(dx: w * 0.1, dy: h * 0.07)
            let diameter = inner.width / 4.3

            ZStack(alignment: .topLeading) {
                jarBody(rect: bodyRect, width: w)

                ForEach(0..<JarView.capacity, id: \.self) { index in
                    let slot = slotPosition(index, inner: inner, diameter: diameter)
                    CookieSprite(diameter: diameter)
                        .rotationEffect(.degrees(JarView.rotations[index % JarView.rotations.count]))
                        .phaseAnimator(DropPhase.allCases, trigger: slotTriggers[index, default: 0]) { content, phase in
                            content
                                .scaleEffect(x: phase.scale.width, y: phase.scale.height, anchor: .bottom)
                                .offset(y: phase == .above ? -(slot.y + diameter * 0.7) : 0)
                        } animation: { phase in
                            phase.animation
                        }
                        .position(slot)
                        .opacity(index < visibleCount ? 1 : 0)
                        .animation(.easeOut(duration: 0.25), value: visibleCount)
                }

                jarLid(width: w, height: lidHeight)
                highlight(rect: bodyRect)
            }
        }
        .aspectRatio(0.66, contentMode: .fit)
        .onChange(of: dropTrigger) { _, newValue in
            guard newValue > 0, visibleCount > 0 else { return }
            slotTriggers[visibleCount - 1] = newValue
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Cookie jar")
        .accessibilityValue("\(cookieCount) cookies")
    }

    // MARK: Layout

    private static let rotations: [Double] = [-8, 6, -4, 10, 3, -7, 9, -2, 5, -9, 2, 7]

    private func slotPosition(_ index: Int, inner: CGRect, diameter: CGFloat) -> CGPoint {
        let perRow = 4
        let row = index / perRow
        let col = index % perRow
        let rowInset = row % 2 == 1 ? diameter * 0.35 : 0
        let usable = inner.width - diameter - rowInset * 2
        let step = perRow > 1 ? usable / CGFloat(perRow - 1) : 0
        let x = inner.minX + rowInset + diameter / 2 + CGFloat(col) * step
        let y = inner.maxY - diameter / 2 - CGFloat(row) * diameter * 0.84
        return CGPoint(x: x, y: y)
    }

    // MARK: Pieces

    private func jarBody(rect: CGRect, width: CGFloat) -> some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: width * 0.1,
            bottomLeadingRadius: width * 0.2,
            bottomTrailingRadius: width * 0.2,
            topTrailingRadius: width * 0.1,
            style: .continuous)
        return ZStack {
            shape.fill(Theme.jarGlass)
            // Faint base shading so the pile has a floor.
            shape
                .fill(LinearGradient(colors: [.clear, Theme.tile.opacity(0.45)], startPoint: .top, endPoint: .bottom))
            shape.strokeBorder(Theme.ink, lineWidth: 3)
            // Thin neck line just under the lid.
            Rectangle()
                .fill(Theme.border)
                .frame(width: rect.width * 0.8, height: 2)
                .position(x: rect.midX, y: rect.minY + rect.height * 0.12)
        }
        .frame(width: rect.width, height: rect.height)
        .offset(y: rect.minY)
    }

    private func jarLid(width: CGFloat, height: CGFloat) -> some View {
        let lidWidth = width * 0.9
        let shape = RoundedRectangle(cornerRadius: height * 0.35, style: .continuous)
        return ZStack {
            shape.fill(Theme.terracotta)
            HStack(spacing: 0) {
                ForEach(0..<13, id: \.self) { _ in
                    Rectangle()
                        .fill(Theme.terracottaDark.opacity(0.7))
                        .frame(width: 1.5)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, height * 0.22)
            .padding(.horizontal, height * 0.3)
            shape.strokeBorder(Theme.ink, lineWidth: 3)
        }
        .frame(width: lidWidth, height: height)
        .offset(x: (width - lidWidth) / 2)
    }

    private func highlight(rect: CGRect) -> some View {
        Capsule()
            .fill(Color.white.opacity(0.75))
            .frame(width: rect.width * 0.06, height: rect.height * 0.42)
            .offset(x: rect.width * 0.14, y: rect.minY + rect.height * 0.16)
    }
}

#Preview("Jar") {
    struct Demo: View {
        @State private var count = 3
        @State private var trigger = 0
        var body: some View {
            VStack(spacing: 24) {
                JarView(cookieCount: count, dropTrigger: trigger)
                    .frame(width: 150)
                HStack {
                    Button("Drop") { count += 1; trigger += 1 }
                    Button("Remove") { count = max(0, count - 1) }
                }
            }
            .padding()
            .background(Theme.cream)
        }
    }
    return Demo()
}
