//
//  ContextProviderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class ContextProviderMock: ContextProvider {
    var receivedId: UUID?
    var context: BatchContext?
    
    func context(with id: UUID) -> BatchContext {
        self.context!
    }
}
