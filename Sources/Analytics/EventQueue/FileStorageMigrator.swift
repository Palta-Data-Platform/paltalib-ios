//
//  FileStorageMigrator.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 02/12/2022.
//

import Foundation

final class FileStorageMigrator {
    private let folderURL: URL
    private let newStorage: EventStorage
    
    
    private let fileManager: FileManager = .default
    private let decoder = JSONDecoder()
    
    init(folderURL: URL, newStorage: EventStorage) {
        self.folderURL = folderURL
        self.newStorage = newStorage
    }
    
    func migrateEvents() throws {
        let files = try fileManager.contentsOfDirectory(atPath: folderURL.path)
        
        for file in files {
            let url = folderURL.appendingPathComponent(file)
            do {
                let data = try Data(contentsOf: url)
                let event = try decoder.decode(Event.self, from: data)
                newStorage.storeEvent(event)
            } catch {
                print("Failed to migrate event at \(url.path)")
            }
            
            try fileManager.removeItem(at: url)
        }
    }
}
