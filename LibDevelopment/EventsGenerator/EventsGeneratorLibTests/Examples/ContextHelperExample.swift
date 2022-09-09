//  

import PaltaLibAnalytics

extension PaltaAnalytics {
    public func editContext(_ editor: (inout Context) -> Void) {
        _editContext(editor)
    }
}
