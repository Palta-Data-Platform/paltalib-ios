//
//  UIViewExtensions.swift
//  AnalyticsTools
//
//  Created by Vyacheslav Beltyukov on 01/06/2022.
//

import UIKit

extension UIView {
    var reversedSubviews: [UIView] {
        subviews.reversed()
    }
    
    var isVisibleByAlpha: Bool {
        !isHidden && alpha >= 0.01
    }
    
    var geometricVisibilityPercentage: CGFloat {
        return trackableFrame.area / frame.area
    }
    
    var trackableFrame: CGRect {
        guard let window = window else {
            return .zero
        }
        
        let convertedFrame = window.convert(bounds, from: self)
        return window.bounds.intersection(convertedFrame)
    }
}
