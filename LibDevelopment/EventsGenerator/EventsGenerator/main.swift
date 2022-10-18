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
    
    return output
}

guard CommandLine.arguments.count >= 3, let host = URL(string: "https://\(CommandLine.arguments[1])") else {
    fatalError("You need to supply host as first argument and API Key as a second argument")
}

let podsPath = CommandLine.arguments
    .first(where: { $0.starts(with: "--podsPath") })
    .flatMap { $0.components(separatedBy: "=").last }

let apiKey = CommandLine.arguments[2]

let currentURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

let configFolderURL = currentURL.appendingPathComponent("config")
let configURL = configFolderURL.appendingPathComponent("config.yaml")

let eventsURL: URL
let eventsTransportURL: URL

if let podsPath = podsPath {
    let podsURL = currentURL.addingRelativePath(podsPath)
    eventsURL = podsURL.appendingPathComponent("PaltaLibEvents/Sources/Events")
    eventsTransportURL = podsURL.appendingPathComponent("PaltaLibEventsTransport/Sources/EventsTransport/config.pb.swift")
} else {
    eventsURL = currentURL.appendingPathComponent("Pods/PaltaLibEvents/Sources/Events")
    eventsTransportURL = currentURL.appendingPathComponent("Pods/PaltaLibEventsTransport/Sources/EventsTransport/config.pb.swift")
}

func prepareProto() throws {
    // TODO: Remove this workaround
    
    try FileManager.default.removeItem(at: configFolderURL.appendingPathComponent("config.proto"))
    try FileManager.default.removeItem(at: configFolderURL.appendingPathComponent("config_v2.proto"))
    
    let protoStrings = try String(
        contentsOf: configFolderURL.appendingPathComponent("config_v1.proto")
    ).components(separatedBy: "\n")
    
    try protoStrings
        .filter { !$0.starts(with: "package paltabrain.") }
        .joined(separator: "\n")
        .write(to: configFolderURL.appendingPathComponent("config.proto"), atomically: true, encoding: .utf8)
    
    try FileManager.default.removeItem(at: configFolderURL.appendingPathComponent("config_v1.proto"))
}

let curlCommand = "curl --location --request GET '\(host.appendingPathComponent("v1/schema"))'"
+ "\\\n --header 'x-api-key: \(apiKey)' --output config.zip"

shell(curlCommand)

shell("unzip config.zip -d config")

try prepareProto()

shell("protoc --swift_out=. config/config.proto --swift_opt=Visibility=Public")

shell("mv -f config/config.pb.swift \(eventsTransportURL.path.replacingOccurrences(of: " ", with: "\\ "))")

shell("chmod -R +w \(eventsURL.path.replacingOccurrences(of: " ", with: "\\ "))")

do {
    try YAMLBasedEventsGenerator(yamlURL: configURL, codeURL: eventsURL).generate()
} catch {
    print("Failed to generate analytics events due to error: \(error)")
}

shell("rm -rf config")
shell("rm -rf config.zip")

private extension URL {
    func addingRelativePath(_ relativePath: String) -> URL {
        var pathComponents = self.pathComponents
        let relativePathComponents = relativePath.components(separatedBy: "/")
        
        for component in relativePathComponents {
            switch component {
            case "..":
                pathComponents.removeLast()
            case ".":
                break
            case "":
                pathComponents = []
            default:
                pathComponents.append(component)
            }
        }
        
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        urlComponents?.path = pathComponents.filter { $0 != "/" }.joined(separator: "/")
        return URL(fileURLWithPath: pathComponents.joined(separator: "/"))
    }
}
