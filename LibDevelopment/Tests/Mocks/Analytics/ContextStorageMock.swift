//
//  ContextStorageMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 24/06/2022.
//

import Foundation
@testable import PaltaLibAnalytics

final class ContextStorageMock: ContextStorage {
    var savedContexts: [BatchContext] = []
    var savedContextsIds: [UUID] = []
    var stripContextsIds: Set<UUID>?
    
    func saveContext(_ context: BatchContext, with id: UUID) throws {
        savedContextsIds.append(id)
        savedContexts.append(context)
    }
    
    func stripContexts(excluding contextIds: Set<UUID>) throws {
        stripContextsIds = contextIds
    }
}
