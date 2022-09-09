//
//  CodeGenerator.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation

final class CodeGenerator {
    private let folderURL: URL
    
    init(folderURL: URL) {
        self.folderURL = folderURL
    }
    
    func genrateCode(filename: String, header: String, imports: [String], statements: [Statement]) throws {
        let url = folderURL.appendingPathComponent("\(filename).swift")
        let codeString = buildGeneratedString(header: header, imports: imports, statements: statements)
        
        try codeString.data(using: .utf8)?.write(to: url)
    }
    
    private func buildGeneratedString(header: String, imports: [String], statements: [Statement]) -> String {
        let headerString = header
            .components(separatedBy: "\n")
            .map { "//  \($0)" }
            .joined(separator: "\n")
        
        let importsString = imports
            .map { "import \($0)" }
            .joined(separator: "\n")
        
        let statementsString = statements
            .map { $0.stringValue(for: 0) }
            .joined(separator: "\n\n")
        
        return [headerString, importsString, statementsString]
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
        + "\n"
    }
}
