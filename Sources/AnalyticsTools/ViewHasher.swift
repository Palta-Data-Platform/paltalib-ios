//
//  ViewHasher.swift
//  AnalyticsTools
//
//  Created by Vyacheslav Beltyukov on 01/06/2022.
//

import UIKit

struct ViewHasher {
    private var hasher = Hasher()
    
    var hash: Int {
        hasher.finalize()
    }
    
    mutating func hash(_ view: UIView) {
        view.center.hash(into: &hasher)
        view.bounds.hash(into: &hasher)
        view.isVisibleByAlpha.hash(into: &hasher)
        
        view.subviews.forEach { hash($0) }
    }
}
