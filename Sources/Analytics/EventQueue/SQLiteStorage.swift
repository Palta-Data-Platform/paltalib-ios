//
//  SQLiteStorage.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 16/12/2022.
//

import Foundation
import SQLite3
import PaltaLibCore
import PaltaLibAnalyticsModel

enum SQliteError: Error {
    case databaseCantBeOpen
    case statementPreparationFailed
    case stepExecutionFailed
    case dataExctractionFailed
    case queryFailed
}

final class SQLiteStorage {
    static func openDatabase(at url: URL) throws -> OpaquePointer {
        var pointer: OpaquePointer?
        
        let result = sqlite3_open_v2(
            url.path.withCString { $0 },
            &pointer,
            SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
            UnsafePointer(nil as UnsafePointer<Int>?)
        )
        
        guard result == SQLITE_OK, let pointer = pointer else {
            throw SQliteError.databaseCantBeOpen
        }
        
        return pointer
    }
    
    private let stack: Stack
    private let db: OpaquePointer
    
    init(folderURL: URL, stack: Stack) throws {
        self.stack = stack
        self.db = try Self.openDatabase(at: folderURL.appendingPathComponent("dbv3.sqlite"))
        
        try populateTables()
    }
    
    private func populateTables() throws {
        try executeStatement("CREATE TABLE IF NOT EXISTS events (event_id BLOB PRIMARY KEY, event_data BLOB);") { executor in
            try executor.runStep()
        }
        try executeStatement("CREATE TABLE IF NOT EXISTS batches (batch_id BLOB PRIMARY KEY, batch_data BLOB);") { executor in
            try executor.runStep()
        }
    }
    
    private func executeStatement<T>(_ statementString: String, _ execution: (StatementExecutor) throws -> T = defaultExecution(_:)) throws -> T {
        var statement: OpaquePointer?
        
        guard
            sqlite3_prepare_v2(db, statementString, -1, &statement, nil) ==
                SQLITE_OK,
            let statement = statement
        else {
            throw SQliteError.statementPreparationFailed
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        let result = try execution(StatementExecutor(statement: statement))
        
        return result
    }
}

extension SQLiteStorage: EventStorage {
    func storeEvent(_ event: StorableEvent) {
        guard let data = try? event.serialize() else {
            return
        }
        
        let row = RowData(column1: event.event.id.data, column2: data)
        
        do {
            try executeStatement("INSERT INTO events (event_id, event_data) VALUES (?, ?)") { executor in
                executor.setRow(row)
                try executor.runStep()
            }
        } catch {
            print("PaltaLib: Analytics: Error saving event: \(error)")
        }
    }
    
    func removeEvent(with id: UUID) {
        do {
            try doRemoveEvent(with: id)
        } catch {
            print("PaltaLib: Analytics: Error removing event: \(error)")
        }
    }
    
    func loadEvents(_ completion: @escaping ([StorableEvent]) -> Void) {
        let results: [StorableEvent]
        
        do {
            results = try executeStatement("SELECT event_id, event_data FROM events") { executor in
                var results: [StorableEvent] = []
                
                while executor.runQuery(), let row = executor.getRow() {
                    do {
                        let event = try StorableEvent(data: row.column2, eventType: stack.event)
                        results.append(event)
                    } catch {
                        print("PaltaLib: Analytics: Error loading single event: \(error)")
                    }
                }
                
                return results as [StorableEvent]
            }
        } catch {
            results = []
            print("PaltaLib: Analytics: Error loading events: \(error)")
        }
                
        completion(results)
    }
    
    private func doRemoveEvent(with id: UUID) throws {
        try executeStatement("DELETE FROM events WHERE event_id = ?") { executor in
            executor.setValue(id.data)
            try executor.runStep()
        }
    }
}

extension SQLiteStorage: BatchStorage2 {
    func loadBatch() throws -> Batch? {
        try executeStatement("SELECT batch_id, batch_data FROM batches") { executor in
            executor.runQuery()
            return try executor.getRow().map { try stack.batch.init(data: $0.column2) }
        }
    }
    
    func saveBatch<IDS: Collection>(_ batch: Batch, with eventIds: IDS) throws where IDS.Element == UUID {
        do {
            try executeStatement("BEGIN TRANSACTION")
            
            try doSaveBatch(batch)
            
            try eventIds.forEach {
                try doRemoveEvent(with: $0)
            }
            
            try executeStatement("COMMIT TRANSACTION")
        } catch {
            try executeStatement("ROLLBACK TRANSACTION")
            throw error
        }
    }
    
    func removeBatch() throws {
        try executeStatement("DELETE FROM batches WHERE TRUE")
    }
    
    private func doSaveBatch(_ batch: Batch) throws {
        let row = RowData(column1: batch.batchId.data, column2: try batch.serialize())
        try executeStatement("INSERT INTO batches (batch_id, batch_data) VALUES (?, ?)") { executor in
            executor.setRow(row)
            try executor.runStep()
        }
    }
}

private struct StatementExecutor {
    let statement: OpaquePointer
    
    func runStep() throws {
        let result = sqlite3_step(statement)
        guard result == SQLITE_DONE else {
            throw SQliteError.stepExecutionFailed
        }
    }
    
    @discardableResult
    func runQuery() -> Bool {
        sqlite3_step(statement) == SQLITE_ROW
    }
    
    func setRow(_ row: RowData) {
        sqlite3_bind_blob(statement, 1, row.column1.withUnsafeBytes { $0.baseAddress }, Int32(row.column1.count), SQLITE_TRANSIENT)
        sqlite3_bind_blob(statement, 2, row.column2.withUnsafeBytes { $0.baseAddress }, Int32(row.column2.count), SQLITE_TRANSIENT)
    }
    
    func setValue(_ value: Data) {
        sqlite3_bind_blob(statement, 1, value.withUnsafeBytes { $0.baseAddress }, Int32(value.count), SQLITE_TRANSIENT)
    }
    
    func getRow() -> RowData? {
        let pointer1 = sqlite3_column_blob(statement, 0)
        let length1 = sqlite3_column_bytes(statement, 0)
        
        let pointer2 = sqlite3_column_blob(statement, 1)
        let length2 = sqlite3_column_bytes(statement, 1)
        
        guard
            let pointer1 = pointer1,
            let pointer2 = pointer2
        else {
            return nil
        }
        
        let data1 = Data(bytes: pointer1, count: Int(length1))
        let data2 = Data(bytes: pointer2, count: Int(length2))
        
        return RowData(column1: data1, column2: data2)
    }
}

private struct RowData {
    let column1: Data
    let column2: Data
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

private func defaultExecution(_ executor: StatementExecutor) throws {
    try executor.runStep()
}
