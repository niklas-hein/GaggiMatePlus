public import SwiftUI

public extension View {
    /// The area one band sweeps across; every `shimmering` view inside it fades under the same band.
    func shimmerSpace() -> some View {
        modifier(ShimmerSpace())
    }

    func shimmering(_ isActive: Bool) -> some View {
        modifier(Shimmering(isActive: isActive))
    }
}

private enum Shimmer {
    static var space: NamedCoordinateSpace { .named("shimmer") }
    static let period: TimeInterval = 3
    static let bandFraction: CGFloat = 0.3 // of the space's width
    static let bandOpacity = 0.35
}

private extension EnvironmentValues {
    @Entry var shimmerWidth: CGFloat = 0
}

private struct ShimmerSpace: ViewModifier {
    @State private var width: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .coordinateSpace(Shimmer.space)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
            .environment(\.shimmerWidth, width)
    }
}

private struct Shimmering: ViewModifier {
    let isActive: Bool

    @Environment(\.shimmerWidth)
    private var spaceWidth

    @State private var frame = CGRect.zero

    @ViewBuilder
    func body(content: Content) -> some View {
        if isActive {
            TimelineView(.animation) { timeline in
                content.mask { band(at: timeline.date) }
            }
            .onGeometryChange(for: CGRect.self) { $0.frame(in: Shimmer.space) } action: { frame = $0 }
        } else {
            content
        }
    }

    // Every view derives the band from the clock and the shared space, so all of them show the same sweep.
    private func band(at date: Date) -> LinearGradient {
        let bandWidth = spaceWidth * Shimmer.bandFraction
        let progress = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: Shimmer.period)
            / Shimmer.period
        let center = (spaceWidth + bandWidth) * progress - bandWidth / 2 - frame.minX
        let width = max(frame.width, 1)
        return LinearGradient(
            colors: [.black, .black.opacity(Shimmer.bandOpacity), .black],
            startPoint: UnitPoint(x: (center - bandWidth / 2) / width, y: 0.5),
            endPoint: UnitPoint(x: (center + bandWidth / 2) / width, y: 0.5)
        )
    }
}
