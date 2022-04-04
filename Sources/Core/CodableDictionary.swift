//
//  CodableDictionary.swift
//  
//
//  Created by Vyacheslav Beltyukov on 31.03.2022.
//

import Foundation

public struct CodableDictionary: Equatable {
    var dictionary: [String: Content]

    subscript(_ key: String) -> Any? {
        set {
            dictionary[key] = newValue.flatMap(Content.init)
        }
        get {
            dictionary[key]?.value
        }
    }

    var asDictonary: [String: Any] {
        dictionary.mapValues {
            $0.value
        }
    }

    init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary.compactMapValues(Content.init)
    }
}

extension CodableDictionary: Codable {
    private struct RandomCodingKey: CodingKey {
        var stringValue: String

        var intValue: Int? {
            nil
        }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }

        init(_ stringValue: String) {
            self.stringValue = stringValue
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RandomCodingKey.self)

        var dictionary: [String: Content] = [:]
        dictionary.reserveCapacity(container.allKeys.count)

        try container.allKeys.forEach {
            dictionary[$0.stringValue] = try container.decode(Content.self, forKey: $0)
        }

        self.dictionary = dictionary
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RandomCodingKey.self)

        try dictionary.forEach {
            try container.encode($0.value, forKey: RandomCodingKey($0.key))
        }
    }
}

extension CodableDictionary {
    enum Content: Codable, Equatable {
        case integer(Int64)
        case double(Double)
        case string(String)
        case boolean(Bool)
        case null
        case dictionary(CodableDictionary)
        case array([Content])

        var value: Any {
            switch self {
            case .integer(let int64):
                return int64
            case .double(let double):
                return double
            case .string(let string):
                return string
            case .boolean(let bool):
                return bool
            case .null:
                return NSNull()
            case .dictionary(let codableDictionary):
                return codableDictionary.asDictonary
            case .array(let array):
                return array.map { $0.value }
            }
        }

        init(from decoder: Decoder) throws {
            if let array = try? Array<Content>(from: decoder) {
                self = .array(array)
                return
            } else if let dictionary = try? CodableDictionary(from: decoder) {
                self = .dictionary(dictionary)
                return
            }

            let singleValueContainer = try decoder.singleValueContainer()

            if let integer = try? singleValueContainer.decode(Int64.self) {
                self = .integer(integer)
            } else if let double = try? singleValueContainer.decode(Double.self) {
                self = .double(double)
            } else if let string = try? singleValueContainer.decode(String.self) {
                self = .string(string)
            } else if let boolean = try? singleValueContainer.decode(Bool.self) {
                self = .boolean(boolean)
            } else if singleValueContainer.decodeNil() {
                self = .null
            } else {
                throw DecodingError.dataCorrupted(
                    .init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Can't decode JSON",
                        underlyingError: nil
                    )
                )
            }
        }

        init?(_ value: Any) {
            if let number = value as? NSNumber, number === kCFBooleanTrue {
                self = .boolean(true)
            } else if let number = value as? NSNumber, number === kCFBooleanFalse {
                self = .boolean(false)
            } else if let number = value as? NSNumber, CFNumberGetType(number as CFNumber).isInteger  {
                self = .integer(number.int64Value)
            } else if let number = value as? NSNumber, CFNumberGetType(number as CFNumber).isDouble {
                self = .double(number.doubleValue)
            } else if value is NSNull  {
                self = .null
            } else if let string = value as? String {
                self = .string(string)
            } else if let array = value as? [Any] {
                self = .array(
                    array.compactMap {
                        guard let content = Content($0) else {
                            assertionFailure()
                            return nil
                        }

                        return content
                    }
                )
            } else if let dictionary = value as? [String: Any] {
                self = .dictionary(CodableDictionary(dictionary))
            } else {
                return nil
            }
        }

        func encode(to encoder: Encoder) throws {
            switch self {
            case .integer(let int64):
                var container = encoder.singleValueContainer()
                try container.encode(int64)
            case .double(let double):
                var container = encoder.singleValueContainer()
                try container.encode(double)
            case .string(let string):
                var container = encoder.singleValueContainer()
                try container.encode(string)
            case .boolean(let bool):
                var container = encoder.singleValueContainer()
                try container.encode(bool)
            case .null:
                var container = encoder.singleValueContainer()
                try container.encodeNil()
            case .dictionary(let codableDictionary):
                try codableDictionary.encode(to: encoder)
            case .array(let array):
                try array.encode(to: encoder)
            }
        }
    }
}

extension CFNumberType {
    var isInteger: Bool {
        switch self {
        case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type, .charType, .shortType, .intType, .longType, .longLongType, .cfIndexType, .nsIntegerType:
            return true

        case .float32Type, .float64Type, .floatType, .doubleType, .cgFloatType, .maxType:
            return false

        default:
            return false
        }
    }

    var isDouble: Bool {
        switch self {
        case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type, .charType, .shortType, .intType, .longType, .longLongType, .cfIndexType, .nsIntegerType:
            return false

        case .float32Type, .float64Type, .floatType, .doubleType, .cgFloatType, .maxType:
            return true

        default:
            return false
        }
    }
}

extension CodableDictionary: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = Any

    public init(dictionaryLiteral elements: (String, Any)...) {
        var dict: [String: Any] = [:]
        dict.reserveCapacity(elements.count)
        elements.forEach {
            dict[$0] = $1
        }

        self.init(dict)
    }
}
