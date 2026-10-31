@testable import Navigation
import Testing

@Suite("Coordinator")
@MainActor
struct CoordinatorTests {
    @Test("The shell starts on Brew with the sidebar closed")
    func startsOnBrew() {
        let coordinator = Coordinator()

        #expect(coordinator.selectedRoot == .brew)
        #expect(!coordinator.isSidebarOpen)
    }

    @Test("The sidebar opens and closes")
    func opensAndCloses() {
        let coordinator = Coordinator()

        coordinator.openSidebar()
        #expect(coordinator.isSidebarOpen)

        coordinator.closeSidebar()
        #expect(!coordinator.isSidebarOpen)
    }

    @Test("Selecting a root shows it and closes the sidebar")
    func selectShowsRoot() {
        let coordinator = Coordinator()
        coordinator.openSidebar()

        coordinator.select(.machine)

        #expect(coordinator.selectedRoot == .machine)
        #expect(!coordinator.isSidebarOpen)
    }
}
