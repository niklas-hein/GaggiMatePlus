import DesignSystem
import SwiftUI

/// An action that fills a card of its own, such as adding or deleting a phase.
struct CardButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    var color = Color.ink
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .headlineText()
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, .spacing20)
                .padding(.vertical, .spacing12)
                .background(.snow, in: .rect(cornerRadius: .radius26))
        }
    }
}
