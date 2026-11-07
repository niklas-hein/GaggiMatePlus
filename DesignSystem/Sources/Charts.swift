public import SwiftUI

public extension CGFloat {
    /// Width to height of a chart, so it scales with the screen.
    static let chartAspectRatio: CGFloat = 2

    /// Width to height of a secondary chart under a main one.
    static let compactChartAspectRatio: CGFloat = 4
}

public extension View {
    /// Sizes a small chart that sits beside text, such as a phase's curve: a fifth of the screen's width, at the
    /// chart ratio.
    func inlineChartFrame() -> some View {
        aspectRatio(.chartAspectRatio, contentMode: .fit)
            .containerRelativeFrame(.horizontal, count: 5, spacing: 0)
    }
}

public extension StrokeStyle {
    /// A chart's data line, thick and with round ends to match the rounded type.
    static var chartLine: StrokeStyle {
        StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
    }

    /// A thin dashed line, for a reference value such as a target.
    static var dashed: StrokeStyle {
        StrokeStyle(lineWidth: 1, dash: [4, 4])
    }
}
