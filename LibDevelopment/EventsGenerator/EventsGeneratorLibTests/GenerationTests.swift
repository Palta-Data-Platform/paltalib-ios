//
//  GenerationTests.swift
//  EventsGeneratorLibTests
//
//  Created by Vyacheslav Beltyukov on 04/07/2022.
//

import Foundation
import XCTest

class GenerationTests: XCTestCase {
    var folderURL: URL!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        folderURL = try FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(UUID().uuidString)
        
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        try FileManager.default.removeItem(at: folderURL)
    }
    
    func replaceExampleData(with generatedData: Data, for filename: String) throws {
        print(url(for: filename))
        try generatedData.write(to: url(for: filename))
    }
    
    func loadExampleData(with name: String) throws -> Data {
        return try Data(contentsOf: url(for: name))
    }
    
    func url(for filename: String) -> URL {
        Bundle
            .init(
                for: StructTests.self
            )
            .url(
                forResource: filename,
                withExtension: "swift",
                subdirectory: "Examples"
            )!
    }
}
