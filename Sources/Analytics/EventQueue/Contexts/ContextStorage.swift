//
//  ContextStorage.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 22/06/2022.
//

import Foundation

protocol ContextStorage {
    func saveContext(_ context: BatchContext, with id: UUID) throws
    func stripContexts(excluding contextIds: Set<UUID>) throws
}

protocol ContextProvider {
    func context(with id: UUID) -> BatchContext
}

final class ContextStorageImpl: ContextStorage, ContextProvider {
    private let folderURL: URL
    private let stack: Stack
    private let fileManager: FileManager
    
    init(folderURL: URL, stack: Stack, fileManager: FileManager) {
        self.folderURL = folderURL
        self.stack = stack
        self.fileManager = fileManager
    }
    
    func context(with id: UUID) -> BatchContext {
        do {
            let url = self.url(for: id)
            let data = try Data(contentsOf: url)
            return try stack.context.init(data: data)
        } catch {
            return stack.context.init()
        }
    }
    
    func saveContext(_ context: BatchContext, with id: UUID) throws {
        let url = self.url(for: id)
        try context.serialize().write(to: url)
    }
    
    func stripContexts(excluding contextIds: Set<UUID>) throws {
        try fileManager
            .contentsOfDirectory(atPath: folderURL.path)
            .filter { $0.hasSuffix(".context") }
            .filter {
                guard let id = UUID(uuidString: $0.replacingOccurrences(of: ".context", with: "")) else {
                    return true
                }
                
                return !contextIds.contains(id)
            }
            .map { folderURL.appendingPathComponent($0) }
            .forEach {
                try fileManager.removeItem(at: $0)
            }
    }
    
    private func url(for contextId: UUID) -> URL {
        folderURL.appendingPathComponent("\(contextId).context")
    }
}
