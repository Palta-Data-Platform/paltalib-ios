//

import PaltaLibAnalytics

public extension PaltaAnalytics {
    func editContext(_ editor: (inout Context) -> Void) {
        _editContext(editor)
    }
}
