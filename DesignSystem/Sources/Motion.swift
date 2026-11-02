public import SwiftUI

public extension Animation {
    /// How a view moves from one state to the next, such as a pill changing its colour and size.
    static var stateChange: Animation {
        .easeInOut(duration: Motion.stateChange)
    }

    /// The first half of a state change, for text that fades out before its replacement fades in.
    static var textFadeOut: Animation {
        .easeIn(duration: Motion.stateChange / 2)
    }

    /// The second half of a state change, for the replacement text fading in.
    static var textFadeIn: Animation {
        .easeOut(duration: Motion.stateChange / 2)
    }
}

private enum Motion {
    static let stateChange: TimeInterval = 0.4
}
