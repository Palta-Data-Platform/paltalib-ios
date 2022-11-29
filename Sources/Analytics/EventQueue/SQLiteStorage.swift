//
//  SQLiteStorage.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 26/11/2022.
//

import Foundation
import SQLite3
import PaltaLibCore

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
    
    private let encoder: JSONEncoder = JSONEncoder().do {
        $0.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.description)
        }
    }
    
    private let decoder: JSONDecoder = .default
    
    private var db: OpaquePointer
    
    init(folderURL: URL) throws {
        self.db = try Self.openDatabase(at: folderURL.appendingPathComponent("db.sqlite"))
        
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
    
    private func executeStatement<T>(_ statementString: String, _ execution: (StatementExecutor) throws -> T) throws -> T {
        var statement: OpaquePointer?
        
        guard
            sqlite3_prepare_v2(db, statementString, -1, &statement, nil) ==
                SQLITE_OK,
            let statement = statement
        else {
            throw SQliteError.statementPreparationFailed
        }
        
        let result = try execution(StatementExecutor(statement: statement))
        
        sqlite3_finalize(statement)
        
        return result
    }
}

extension SQLiteStorage: EventStorage {
    func storeEvent(_ event: Event) {
        let row = RowData(column1: event.insertId.data, column2: try! encoder.encode(event))
        try! executeStatement("INSERT INTO events (event_id, event_data) VALUES (?, ?)") { executor in
            executor.setRow(row)
            try executor.runStep()
        }
    }
    
    func removeEvent(_ event: Event) {
        try! executeStatement("DELETE FROM events WHERE event_id = ?") { executor in
            executor.setValue(event.insertId.data)
            try executor.runStep()
        }
    }
    
    func loadEvents(_ completion: @escaping ([Event]) -> Void) {
        let results = try! executeStatement("SELECT event_id, event_data FROM events") { executor in
            var results: [Event] = []
            
            while executor.runQuery(), let row = executor.getRow() {
                if let event = try? decoder.decode(Event.self, from: row.column2) {
                    results.append(event)
                }
            }
            
            return results
        }
        
        completion(results)
    }
}

private struct StatementExecutor {
    let statement: OpaquePointer
    
    func runStep() throws {
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQliteError.stepExecutionFailed
        }
    }
    
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
