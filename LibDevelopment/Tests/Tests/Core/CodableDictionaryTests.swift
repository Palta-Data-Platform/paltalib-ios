//
//  CodableDictionaryTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 01.04.2022.
//

@testable import PaltaLibCore
import XCTest

final class CodableDictionaryTests: XCTestCase {
    func testInitFromDictionary() {
        let originalDictionary: [String: Any] = [
            "integer": 1,
            "double": 2.5,
            "true": true,
            "false": false,
            "integerNSNumber": 2 as NSNumber,
            "boolNSNumber": true as NSNumber,
            "doubleNSNumber": 3.5 as NSNumber,
            "string": "aString",
            "null": NSNull(),
            "dictionary": ["key": "value"],
            "array": [3]
        ]

        let codableDictionary = CodableDictionary(originalDictionary)

        XCTAssertEqual(codableDictionary.dictionary["integer"], .integer(1))
        XCTAssertEqual(codableDictionary.dictionary["double"], .double(2.5))
        XCTAssertEqual(codableDictionary.dictionary["true"], .boolean(true))
        XCTAssertEqual(codableDictionary.dictionary["false"], .boolean(false))
        XCTAssertEqual(codableDictionary.dictionary["integerNSNumber"], .integer(2))
        XCTAssertEqual(codableDictionary.dictionary["boolNSNumber"], .boolean(true))
        XCTAssertEqual(codableDictionary.dictionary["doubleNSNumber"], .double(3.5))
        XCTAssertEqual(codableDictionary.dictionary["string"], .string("aString"))
        XCTAssertEqual(codableDictionary.dictionary["null"], .null)
        XCTAssertEqual(
            codableDictionary.dictionary["dictionary"],
            .dictionary(CodableDictionary(["key": "value"]))
        )
        XCTAssertEqual(codableDictionary.dictionary["array"], .array([.integer(3)]))
    }

    func testDecode() throws {
        let json = """
        {
            "integer": 1,
            "double": 2.5,
            "true": true,
            "false": false,
            "string": "aString",
            "null": null,
            "dictionary": {"key": "value"},
            "array": [3]
        }
        """.data(using: .utf8)!

        let codableDictionary = try JSONDecoder().decode(CodableDictionary.self, from: json)

        XCTAssertEqual(codableDictionary.dictionary["integer"], .integer(1))
        XCTAssertEqual(codableDictionary.dictionary["double"], .double(2.5))
        XCTAssertEqual(codableDictionary.dictionary["true"], .boolean(true))
        XCTAssertEqual(codableDictionary.dictionary["false"], .boolean(false))
        XCTAssertEqual(codableDictionary.dictionary["string"], .string("aString"))
        XCTAssertEqual(codableDictionary.dictionary["null"], .null)
        XCTAssertEqual(
            codableDictionary.dictionary["dictionary"],
            .dictionary(CodableDictionary(["key": "value"]))
        )
        XCTAssertEqual(codableDictionary.dictionary["array"], .array([.integer(3)]))
    }

    func testGetDictionary() {
        var codableDictionary = CodableDictionary([:])

        codableDictionary.dictionary = [
            "integer": .integer(1),
            "double": .double(2.5),
            "true": .boolean(true),
            "false": .boolean(false),
            "string": .string("aString"),
            "null": .null,
            "dictionary": .dictionary(CodableDictionary(["key": "value"])),
            "array": .array([.integer(3)])
        ]

        let outputDictionary = codableDictionary.asDictonary

        XCTAssertEqual(outputDictionary["integer"] as? Int64, 1)
        XCTAssertEqual(outputDictionary["double"] as? Double, 2.5)
        XCTAssertEqual(outputDictionary["true"] as? Bool, true)
        XCTAssertEqual(outputDictionary["false"] as? Bool, false)
        XCTAssertEqual(outputDictionary["string"] as? String, "aString")
        XCTAssert(outputDictionary["null"] is NSNull)
        XCTAssertEqual(outputDictionary["dictionary"] as? [String: String], ["key": "value"])
        XCTAssertEqual(outputDictionary["array"] as? [Int64], [3])
    }

    func testEncode() throws {
        var codableDictionary = CodableDictionary([:])

        codableDictionary.dictionary = [
            "integer": .integer(1),
            "double": .double(2.5),
            "true": .boolean(true),
            "false": .boolean(false),
            "string": .string("aString"),
            "null": .null,
            "dictionary": .dictionary(CodableDictionary(["key": "value"])),
            "array": .array([.integer(3)])
        ]

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let outputString = try String(data: encoder.encode(codableDictionary), encoding: .utf8)

        let desiredString = """
        {
          "array" : [
            3
          ],
          "dictionary" : {
            "key" : "value"
          },
          "double" : 2.5,
          "false" : false,
          "integer" : 1,
          "null" : null,
          "string" : "aString",
          "true" : true
        }
        """

        XCTAssertEqual(outputString, desiredString)
    }

    func testInitAndEncode() throws {
        let originalDictionary: [String: Any] = [
            "integer": 1,
            "double": 2.5,
            "true": true,
            "false": false,
            "integerNSNumber": 2 as NSNumber,
            "boolNSNumber": true as NSNumber,
            "doubleNSNumber": 3.5 as NSNumber,
            "string": "aString",
            "null": NSNull(),
            "dictionary": ["key": "value"],
            "array": [3],
            "date": Date(timeIntervalSince1970: 1)
        ]

        let codableDictionary = CodableDictionary(originalDictionary)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let outputString = try String(data: encoder.encode(codableDictionary), encoding: .utf8)

        let desiredString = """
        {
          "array" : [
            3
          ],
          "boolNSNumber" : true,
          "date" : 1000,
          "dictionary" : {
            "key" : "value"
          },
          "double" : 2.5,
          "doubleNSNumber" : 3.5,
          "false" : false,
          "integer" : 1,
          "integerNSNumber" : 2,
          "null" : null,
          "string" : "aString",
          "true" : true
        }
        """

        XCTAssertEqual(outputString, desiredString)
    }

    func testDecodeAndExport() throws {
        let json = """
        {
            "integer": 1,
            "double": 2.5,
            "true": true,
            "false": false,
            "string": "aString",
            "null": null,
            "dictionary": {"key": "value"},
            "array": [3]
        }
        """.data(using: .utf8)!

        let codableDictionary = try JSONDecoder().decode(CodableDictionary.self, from: json)

        let outputDictionary = codableDictionary.asDictonary

        XCTAssertEqual(outputDictionary["integer"] as? Int64, 1)
        XCTAssertEqual(outputDictionary["double"] as? Double, 2.5)
        XCTAssertEqual(outputDictionary["true"] as? Bool, true)
        XCTAssertEqual(outputDictionary["false"] as? Bool, false)
        XCTAssertEqual(outputDictionary["string"] as? String, "aString")
        XCTAssert(outputDictionary["null"] is NSNull)
        XCTAssertEqual(outputDictionary["dictionary"] as? [String: String], ["key": "value"])
        XCTAssertEqual(outputDictionary["array"] as? [Int64], [3])
    }
}
