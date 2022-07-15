//
//  CurrentContextProviderMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel
@testable import PaltaLibAnalytics

final class CurrentContextProviderMock: CurrentContextProvider {
    var context: BatchContext = BatchContextMock()
    var currentContextId: UUID = UUID()
}
