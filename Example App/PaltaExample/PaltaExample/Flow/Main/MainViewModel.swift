import Foundation
import PaltaLib

protocol MainViewModelInterface: AnyObject {
    func logTestEvent()
}

final class MainViewModel: MainViewModelInterface {
    
    public func logTestEvent() {
        PaltaLib.instance.logEvent("test_button_tapped")
    }
}
