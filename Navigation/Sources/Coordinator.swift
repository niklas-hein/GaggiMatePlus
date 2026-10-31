public import Observation

@MainActor
@Observable
public final class Coordinator {
    public private(set) var selectedRoot: ShellRoot = .brew
    public private(set) var isSidebarOpen = false

    public init() {}

    public func select(_ root: ShellRoot) {
        selectedRoot = root
        closeSidebar()
    }

    public func openSidebar() {
        isSidebarOpen = true
    }

    public func closeSidebar() {
        isSidebarOpen = false
    }
}
