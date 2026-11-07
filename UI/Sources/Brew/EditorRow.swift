import DesignSystem
import SwiftUI

/// A titled value on an editor card, edited in place.
struct EditorRow<Value: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let value: Value

    init(_ title: LocalizedStringKey, @ViewBuilder value: () -> Value) {
        self.title = title
        self.value = value()
    }

    var body: some View {
        HStack(spacing: .spacing12) {
            Text(title)
                .foregroundStyle(.ink)
            Spacer(minLength: 0)
            HStack(spacing: .spacing8) {
                value
            }
            .multilineTextAlignment(.trailing)
            .monospacedDigit()
            .foregroundStyle(.slate)
        }
        .headlineText()
        .padding(.horizontal, .spacing20)
        .padding(.vertical, .spacing12)
    }
}
