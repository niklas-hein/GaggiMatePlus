public import SwiftUI
import UIKit

public extension View {
    /// The screen's title, inline in a bar that hides while scrolling down and fades softly into the content.
    ///
    /// Inline because on iOS 27 pushing a scrolling screen with a large title, while the current screen's
    /// bar is hidden, loops its layout forever.
    func navigationBar(title: LocalizedStringKey) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)
            .scrollEdgeEffectStyle(.soft, for: .top)
    }
}

public enum NavigationBarTitles {
    /// Sets the title of every navigation bar in SF Pro Rounded.
    @MainActor
    public static func useRoundedFonts() {
        let bar = UINavigationBar.appearance()
        bar.titleTextAttributes = [.font: UIFont.rounded(.headline, weight: .semibold)]
    }
}

private extension UIFont {
    static func rounded(_ style: TextStyle, weight: Weight) -> UIFont {
        let size = preferredFont(forTextStyle: style).pointSize
        let descriptor = systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(.rounded)!
        return UIFont(descriptor: descriptor, size: size)
    }
}
