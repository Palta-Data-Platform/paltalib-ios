//
//  BackgroundNotifierMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/09/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class BackgroundNotifierMock: BackgroundNotifier {
    var listener: (() -> Void)?
    
    func addListener(_ listener: @escaping () -> Void) {
        self.listener = listener
    }
}
