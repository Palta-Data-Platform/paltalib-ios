import Foundation
import PaltaLibAnalytics
import PaltaEvents

protocol AnalyticsModelInterface: AnyObject {
    func logTestEvent()
    func changeContext()
    func loadTest()
}

final class AnalyticsViewModel: AnalyticsModelInterface {
    private var counter = 0
    
    func logTestEvent() {
        counter += 1
        PaltaAnalytics.shared.log(
            PageOpenEvent(pageID: "\(counter)")
        )
    }
    
    func changeContext() {
        PaltaAnalytics.shared.editContext { context in
            context.appsflyer = .init(appsflyerID: UUID().uuidString)
        }
    }
    
    func loadTest() {
        DispatchQueue.global().async {
            DispatchQueue.concurrentPerform(iterations: 5) { _ in
                for _ in 1...1000 {
                    PaltaAnalytics.shared.log(PageOpenEvent(pageID: UUID().uuidString))
                }
            }
        }
        
        DispatchQueue.global().async {
            DispatchQueue.concurrentPerform(iterations: 3) { _ in
                for _ in 1...500 {
                    PaltaAnalytics.shared.editContext { context in
                        context.appsflyer = .init(appsflyerID: UUID().uuidString)
                    }
                }
            }
        }
    }
}
