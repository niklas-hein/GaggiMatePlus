import DesignSystem
import Navigation
import SwiftUI

struct SidebarContainer<Foreground: View, Sidebar: View>: View {
    @Environment(Coordinator.self)
    private var coordinator

    @State private var containerWidth: CGFloat = 0
    @State private var safeAreaInsets = EdgeInsets()
    @State private var dragProgress: CGFloat?

    private let foreground: Foreground
    private let sidebar: Sidebar

    init(@ViewBuilder foreground: () -> Foreground, @ViewBuilder sidebar: () -> Sidebar) {
        self.foreground = foreground()
        self.sidebar = sidebar()
    }

    var body: some View {
        // The layers ignore the safe area so the foreground's rounding and offset reach the screen's
        // edges; each layer gets the measured insets back as padding.
        Color.clear
            .onGeometryChange(for: EdgeInsets.self) { $0.safeAreaInsets } action: { safeAreaInsets = $0 }
            .overlay {
                layers
                    .ignoresSafeArea()
            }
    }

    private var layers: some View {
        ZStack(alignment: .leading) {
            Color.cream

            sidebarLayer

            foregroundLayer
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { containerWidth = $0 }
        .gesture(
            SidebarPanGesture(
                progress: $dragProgress,
                sidebarWidth: sidebarWidth,
                isOpen: coordinator.isSidebarOpen,
                settle: settle(open:)
            )
        )
        .animation(SidebarMotion.animation, value: coordinator.isSidebarOpen)
    }

    private var sidebarLayer: some View {
        sidebar
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaPadding(
                EdgeInsets(
                    top: safeAreaInsets.top,
                    leading: safeAreaInsets.leading,
                    bottom: safeAreaInsets.bottom,
                    trailing: 0
                )
            )
            .frame(width: sidebarWidth)
            .frame(maxHeight: .infinity)
            .offset(x: -SidebarLayout.parallax * (1 - progress))
            .allowsHitTesting(coordinator.isSidebarOpen)
    }

    private var foregroundLayer: some View {
        foreground
            .safeAreaPadding(safeAreaInsets)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.cream)
            .overlay {
                Color.cream
                    .opacity(SidebarLayout.foregroundDimming * Double(progress))
                    .allowsHitTesting(false)
            }
            .overlay {
                dismissTarget
            }
            .clipShape(.rect(cornerRadius: SidebarLayout.foregroundCornerRadius * progress))
            .shadow(
                color: SidebarLayout.shadowColor.opacity(SidebarLayout.shadowOpacity * progress),
                radius: SidebarLayout.shadowRadius * progress,
                x: -SidebarLayout.shadowOffset * progress,
                y: 0
            )
            .offset(x: sidebarWidth * progress)
    }

    private var dismissTarget: some View {
        Button {
            coordinator.closeSidebar()
        } label: {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(coordinator.isSidebarOpen)
    }

    private func settle(open: Bool) {
        withAnimation(SidebarMotion.animation) {
            if open {
                coordinator.openSidebar()
            } else {
                coordinator.closeSidebar()
            }
            dragProgress = nil
        }
    }

    private var sidebarWidth: CGFloat {
        min(containerWidth * SidebarLayout.widthFraction, SidebarLayout.maximumWidth)
    }

    private var progress: CGFloat {
        dragProgress ?? (coordinator.isSidebarOpen ? 1 : 0)
    }
}
