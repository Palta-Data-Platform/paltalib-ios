//
//  main.swift
//  EventsGenerator
//
//  Created by Vyacheslav Beltyukov on 01/07/2022.
//

import Foundation
import EventsGeneratorStatic

@discardableResult
func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    print(output)
    
    return output
}

let curerentURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

shell("tar -xzvf config.tar.gz")

try YAMLBasedEventsGenerator(yamlURL: curerentURL.appendingPathComponent("config.yaml"), codeURL: curerentURL).generate()
