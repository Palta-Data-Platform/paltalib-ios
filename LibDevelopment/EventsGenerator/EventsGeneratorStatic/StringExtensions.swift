//
//  StringExtensions.swift
//  EventsGeneratorLib
//
//  Created by Vyacheslav Beltyukov on 05/07/2022.
//

import Foundation

extension String {
    var startLowercase: String {
        guard let first = first else {
            return ""
        }
        
        return first.lowercased() + suffix(from: index(after: startIndex))
    }
    
    var snakeCaseToCamelCase: String {
        self
            .components(separatedBy: "_")
            .enumerated()
            .map { index, string in
                guard index > 0 else {
                    return string
                }
                
                if string == "id" {
                    return "ID"
                } else {
                    return string.capitalized
                }
            }
            .joined(separator: "")
    }
    
    var camelCaseToSnakeCase: String {
        let upperCaseIndices = allIndicies(where: {
            return CharacterSet.uppercaseLetters.contains($0.unicodeScalars.first!) || CharacterSet.decimalDigits.contains($0.unicodeScalars.first!)
        }).reversed()
        
        var copy = self
        let lowercased = self.lowercased()
        
        upperCaseIndices.forEach { index in
            guard index != startIndex else {
                return
            }
            
            copy.remove(at: index)
            copy.insert(lowercased[index], at: index)
            copy.insert("_", at: index)
        }
        
        return copy
    }
}

extension String {
    func allIndicies(of element: Element) -> [Index] {
        allIndicies {
            $0 == element
        }
    }
    
    func allIndicies(where filter: (Element) -> Bool) -> [Index] {
        indices.filter {
            filter(self[$0])
        }
    }
}
