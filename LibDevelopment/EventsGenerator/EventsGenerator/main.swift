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

guard CommandLine.arguments.count == 3, let host = URL(string: "https://\(CommandLine.arguments[1])") else {
    fatalError("You need to supply host as first argument and API Key as a second argument")
}

let apiKey = CommandLine.arguments[2]

let currentURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

let configFolderURL = currentURL.appendingPathComponent("config")
let configURL = configFolderURL.appendingPathComponent("config.yaml")
let eventsURL = currentURL.appendingPathComponent("Pods/PaltaLibEvents/Sources/Events")

let curlCommand = "curl --location --request GET '\(host.appendingPathComponent("v1/schema"))'"
+ "\\\n --header 'x-api-key: \(apiKey)' --output config.zip"

shell(curlCommand)

shell("unzip config.zip -d config")

shell("protoc --swift_out=. config/config.proto --swift_opt=Visibility=Public")

shell("mv -f config/config.pb.swift Pods/PaltaLibEventsTransport/Sources/EventsTransport/config.pb.swift")

shell("chmod -R +w Pods/PaltaLibEvents/Sources/Events/")

do {
    try YAMLBasedEventsGenerator(yamlURL: configURL, codeURL: eventsURL).generate()
} catch {
    print("Failed to generate analytics events due to error: \(error)")
}

shell("rm -rf config")
shell("rm -rf config.zip")
