public import SwiftUI

public extension View {
    func headlineText() -> some View {
        font(.system(.headline, design: .rounded))
    }

    func secondarySubheadlineText() -> some View {
        font(.system(.subheadline, design: .rounded))
            .textScale(.secondary)
    }
}
