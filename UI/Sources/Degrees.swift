import Foundation

extension Double {
    var degrees: String {
        formatted(.number.precision(.fractionLength(0))) + "°"
    }
}
