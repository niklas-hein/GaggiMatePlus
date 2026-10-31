import DesignSystem
import SwiftUI
import UIKit

struct SidebarPanGesture: UIGestureRecognizerRepresentable {
    @Binding var progress: CGFloat?
    let sidebarWidth: CGFloat
    let isOpen: Bool
    let settle: (_ open: Bool) -> Void

    func makeCoordinator(converter _: CoordinateSpaceConverter) -> Delegate {
        Delegate()
    }

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = context.coordinator
        recognizer.cancelsTouchesInView = false
        return recognizer
    }

    func updateUIGestureRecognizer(_: UIPanGestureRecognizer, context: Context) {
        context.coordinator.isOpen = isOpen
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context _: Context) {
        guard let view = recognizer.view, sidebarWidth > 0 else {
            return
        }
        let start: CGFloat = isOpen ? 1 : 0

        switch recognizer.state {
        case .began, .changed:
            let translation = recognizer.translation(in: view).x
            progress = min(1, max(0, start + translation / sidebarWidth))

        case .ended:
            let velocity = recognizer.velocity(in: view).x
            let isFlick = abs(velocity) > SidebarLayout.flickVelocity
            settle(isFlick ? velocity > 0 : (progress ?? start) >= SidebarLayout.settleThreshold)

        case .cancelled, .failed:
            settle(isOpen)

        default:
            break
        }
    }

    @MainActor
    final class Delegate: NSObject, UIGestureRecognizerDelegate {
        var isOpen = false

        func gestureRecognizerShouldBegin(_ recognizer: UIGestureRecognizer) -> Bool {
            guard let pan = recognizer as? UIPanGestureRecognizer, let view = pan.view else {
                return false
            }
            let velocity = pan.velocity(in: view)
            guard abs(velocity.x) > abs(velocity.y) * SidebarLayout.horizontalBias else {
                return false
            }
            if isOpen {
                return velocity.x < 0
            }
            guard velocity.x > 0 else {
                return false
            }
            let touchDownX = pan.location(in: view).x - pan.translation(in: view).x
            return touchDownX <= SidebarLayout.edgeWidth
        }
    }
}
