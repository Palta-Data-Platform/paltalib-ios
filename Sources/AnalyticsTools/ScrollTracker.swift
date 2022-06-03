//
//  ScrollTracker.swift
//  AnalyticsTools
//
//  Created by Vyacheslav Beltyukov on 03/06/2022.
//

import Foundation
import UIKit

public final class ScrollTracker {
    private let interceptingDelegate: InterceptingDelegate
    
    public init(scrollView: UIScrollView, tracker: @escaping () -> Void) {
        let interceptingDelegate = InterceptingDelegate(
            originalDelegate: scrollView.delegate as? NSObject & UIScrollViewDelegate ?? EmptyDelegate(),
            tracker: tracker
        )
        
        scrollView.delegate = interceptingDelegate
        
        self.interceptingDelegate = interceptingDelegate
    }
}

private class InterceptingDelegate: NSObject, UIScrollViewDelegate {
    private let originalDelegate: NSObject & UIScrollViewDelegate
    private let tracker: () -> Void
    
    init(
        originalDelegate: NSObject & UIScrollViewDelegate,
        tracker: @escaping () -> Void
    ) {
        self.originalDelegate = originalDelegate
        self.tracker = tracker
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        originalDelegate.responds(to: aSelector) || aSelector == #selector(scrollViewDidEndDragging(_:willDecelerate:))
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        guard aSelector != #selector(scrollViewDidEndDragging(_:willDecelerate:)) else {
            return nil
        }
        
        return originalDelegate
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        tracker()
        
        originalDelegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}

private final class EmptyDelegate: NSObject, UIScrollViewDelegate {}
