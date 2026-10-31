import Navigation
import SwiftUI
import UI

struct RootView: View {
    var body: some View {
        ShellView()
    }
}

#Preview {
    RootView()
        .environment(Coordinator())
}
