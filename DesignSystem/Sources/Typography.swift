public import SwiftUI

public extension View {
    func heavyLargeTitleText() -> some View {
        font(.system(.largeTitle, design: .rounded, weight: .heavy))
    }

    func boldTitle2Text() -> some View {
        font(.system(.title2, design: .rounded, weight: .bold))
    }

    func headlineText() -> some View {
        font(.system(.headline, design: .rounded))
    }

    func boldHeadlineText() -> some View {
        font(.system(.headline, design: .rounded, weight: .bold))
    }

    func subheadlineText() -> some View {
        font(.system(.subheadline, design: .rounded))
    }

    func boldSubheadlineText() -> some View {
        font(.system(.subheadline, design: .rounded, weight: .bold))
    }

    func secondarySubheadlineText() -> some View {
        font(.system(.subheadline, design: .rounded))
            .textScale(.secondary)
    }
}
