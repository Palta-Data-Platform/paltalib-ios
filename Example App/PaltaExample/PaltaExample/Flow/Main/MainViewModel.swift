import Foundation
import PaltaLibAnalytics

protocol MainViewModelInterface: AnyObject {
    func logTestEvent()
}

final class MainViewModel: MainViewModelInterface {
    
    public func logTestEvent() {
        PaltaAnalytics.instance.logEvent("test_button_tapped")
    }
}
