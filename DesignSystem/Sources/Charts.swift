public import SwiftUI

public extension CGFloat {
    /// Width to height of a chart, so it scales with the screen.
    static let chartAspectRatio: CGFloat = 2

    /// Width to height of a secondary chart under a main one.
    static let compactChartAspectRatio: CGFloat = 4
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
