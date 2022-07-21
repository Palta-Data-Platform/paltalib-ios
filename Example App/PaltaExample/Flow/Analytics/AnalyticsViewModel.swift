import Foundation
import PaltaLibAnalytics
import PaltaEvents

protocol AnalyticsModelInterface: AnyObject {
    func logTestEvent()
}

final class AnalyticsViewModel: AnalyticsModelInterface {
    public func logTestEvent() {
        PaltaAnalytics.shared.log(
            EdgeCaseEvent(
                header: .init(),
                propBoolean: true,
                propBooleanArray: [false, true],
                propDecimal1: 0.5,
                propDecimal2: 0.888,
                propDecimalArray: [0.1, 0.2, 0.3],
                propEnum: .skip,
                propEnumArray: [.error, .success],
                propInteger: 25,
                propIntegerArray: [0, 1, 2],
                propString: "aString",
                propStringArray: ["03", "02", "01"],
                propTimestamp: 200,
                propTimestampArray: [200, 300, 400]
            )
        )
    }
}
