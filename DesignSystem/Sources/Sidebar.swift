public import SwiftUI

public enum SidebarLayout {
    public static let maximumWidth: CGFloat = 320
    public static let widthFraction: CGFloat = 0.8
    public static let parallax: CGFloat = .spacing32
    public static let foregroundCornerRadius: CGFloat = 64
    public static let foregroundDimming = 0.75
    public static let shadowColor = Color.black
    public static let shadowOpacity = 0.2
    public static let shadowRadius: CGFloat = .radius8
    public static let shadowOffset: CGFloat = .spacing8

    public static let edgeWidth: CGFloat = .spacing32
    public static let flickVelocity: CGFloat = 350 // pt/s
    public static let horizontalBias: CGFloat = 1.2
    public static let settleThreshold: CGFloat = 0.5

    public static let machineRowHeight: CGFloat = 66
    public static let machineDiscSize: CGFloat = 42
}

public enum SidebarMotion {
    public static let animation: Animation = .snappy(duration: 0.33, extraBounce: 0.1)
}
