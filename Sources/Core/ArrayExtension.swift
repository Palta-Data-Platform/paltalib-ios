//
//  ArrayExtension.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 12/05/2022.
//

import Foundation

public extension Array {
    func nextElement(after check: (Element) -> Bool) -> Element? {
        guard
            let index = firstIndex(where: check).map({ $0 + 1 }),
            indices.contains(index)
        else {
            return nil
        }
        
        return self[index]
    }
}
