//
//  ArrayExtensions.swift
//  EventsGeneratorStatic
//
//  Created by Vyacheslav Beltyukov on 08/08/2022.
//

import Foundation
import CloudKit
import Metal

func zip<Element1, Element2>(_ array1: [Element1], _ array2: [Element2]) -> [(Element1, Element2)] {
    assert(array1.count == array2.count)
    
    var resultArray: [(Element1, Element2)] = []
    resultArray.reserveCapacity(array1.count)
    
    for i in 0..<array1.count {
        resultArray.append((array1[i], array2[i]))
    }
    
    return resultArray
}
