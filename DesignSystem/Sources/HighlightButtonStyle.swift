public import SwiftUI

/// A row with a rounded background tinted by the foreground colour: lightly while selected, more while pressed.
public struct HighlightButtonStyle: ButtonStyle {
    private static let selectedOpacity = 0.04
    private static let pressedOpacity = 0.08

    let isSelected: Bool

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, .spacing12)
            .background(
                .foreground.opacity(opacity(isPressed: configuration.isPressed)),
                in: .rect(cornerRadius: .radius12)
            )
            .contentShape(.rect(cornerRadius: .radius12))
    }

    private func opacity(isPressed: Bool) -> Double {
        if isPressed {
            Self.pressedOpacity
        } else if isSelected {
            Self.selectedOpacity
        } else {
            0
        }
    }
}

public extension ButtonStyle where Self == HighlightButtonStyle {
    static func highlight(isSelected: Bool) -> Self {
        Self(isSelected: isSelected)
    }
}
