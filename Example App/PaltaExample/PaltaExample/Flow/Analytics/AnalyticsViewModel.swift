import Foundation
import PaltaLibAnalytics

protocol AnalyticsModelInterface: AnyObject {
    func logTestEvent()
}

final class AnalyticsViewModel: AnalyticsModelInterface {
    public func logTestEvent() {
        PaltaAnalytics.instance.logEvent("test_button_tapped")
    }
}
