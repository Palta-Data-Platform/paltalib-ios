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
        let underscoreIndecies = allIndicies(of: "_").reversed()
        
        var copy = self
        let uppercased = self.uppercased()
        
        underscoreIndecies.forEach { index in
            let nextIndex = self.index(after: index)
            
            guard indices.contains(nextIndex), index != startIndex else {
                return
            }
            
            copy.replaceSubrange(nextIndex...nextIndex, with: uppercased[nextIndex...nextIndex])
            copy.remove(at: index)
        }
        
        return copy
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
