//
//  ScreenMap.swift
//  AnalyticsTools
//
//  Created by Vyacheslav Beltyukov on 01/06/2022.
//

import UIKit

class ScreenMap {
    private let width: Int
    private let height: Int
    
    private lazy var area = CGFloat(width * height)
    
    private var ranges: [IndexSet] = []
    
    init(
        width: Int = Int(UIScreen.main.bounds.width),
        height: Int = Int(UIScreen.main.bounds.height)
    ) {
        self.width = width
        self.height = height
        
        reset()
    }
    
    func overlap(with rect: CGRect) -> CGFloat {
        let (xValues, yValues) = iterationParameters(for: rect)
        var overlapArea = 0
        
        for x in xValues {
            overlapArea += ranges[x].intersection(yValues).count
        }
        
        return CGFloat(overlapArea) / area
    }
    
    func insert(_ rect: CGRect) {
        guard rect.isValid else {
            return
        }
        
        let (xValues, yValues) = iterationParameters(for: rect)
        
        for x in xValues {
            ranges[x].formUnion(yValues)
        }
    }
    
    func merge(with screenMap: ScreenMap) {
        for x in ranges.indices {
            ranges[x].formUnion(screenMap.ranges[x])
        }
    }
    
    func reset() {
        ranges = Array(repeating: [], count: width)
    }
    
    private func iterationParameters(for rect: CGRect) -> (ClosedRange<Int>, IndexSet) {
        let minX = min(Int(rect.minX), width-1)
        let maxX = min(Int(rect.maxX), width-1)
        let minY = min(Int(rect.minY), height-1)
        let maxY = min(Int(rect.maxY), height-1)
        
        return (minX...maxX, IndexSet(minY...maxY))
    }
}
