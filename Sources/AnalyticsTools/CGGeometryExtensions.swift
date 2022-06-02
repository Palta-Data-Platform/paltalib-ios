//
//  CGGeometryExtensions.swift
//  AnalyticsTools
//
//  Created by Vyacheslav Beltyukov on 01/06/2022.
//

import CoreGraphics

extension CGFloat {
    var isValid: Bool {
        isFinite && !isNaN
    }
}

extension CGRect {
    var area: CGFloat {
        width * height
    }
    
    var isValid: Bool {
        maxX.isValid && minX.isValid && minY.isValid && maxY.isValid
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        x.hash(into: &hasher)
        y.hash(into: &hasher)
    }
}

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        width.hash(into: &hasher)
        height.hash(into: &hasher)
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        origin.hash(into: &hasher)
        size.hash(into: &hasher)
    }
}
