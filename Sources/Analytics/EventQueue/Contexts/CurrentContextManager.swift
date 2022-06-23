//
//  CurrentContextManager.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 22/06/2022.
//

import Foundation

protocol ContextModifier {
    func editContext(_ editor: (inout BatchContext) -> Void)
    func stripContexts(excluding contextIds: Set<UUID>)
}

protocol CurrentContextProvider {
    var context: BatchContext { get }
    var currentContextId: UUID { get }
}
