//
//  TemplateGenerator.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation

protocol Template {
    var filename: String { get }
    var imports: [String] { get }
    var statements: [Statement] { get }
}

final class TemplateGenerator {
    private let template: Template
    private let codeGenerator: CodeGenerator
    
    init(template: Template, folderURL: URL) {
        self.template = template
        self.codeGenerator = CodeGenerator(folderURL: folderURL)
    }
    
    func generate() throws {
        try codeGenerator.genrateCode(
            filename: template.filename,
            header: "",
            imports: template.imports,
            statements: template.statements
        )
    }
}
