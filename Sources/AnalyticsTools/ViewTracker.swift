//
//  ViewTracker.swift
//  AnalyticsTools
//
//  Created by Vyacheslav Beltyukov on 30/05/2022.
//

import UIKit

public final class ViewTracker {
    private let viewTracker: (TrackableView) -> Void
    private let groupTracker: (AnyHashable) -> Void
    
    private let threshold: CGFloat = 0.5
    private let trackRateHz: Double = 5
    
    private var previousHash = 0
    private var shownViewIdentifiers: Set<AnyHashable> = []
    private var shownGroupIdentifiers: Set<AnyHashable> = []
    
    private var timerScheduled = false
    
    private var runLoopObserver: RunLoopObserver?
    
    public init(
        viewTracker: @escaping (TrackableView) -> Void,
        groupTracker: @escaping (AnyHashable) -> Void
    ) {
        self.viewTracker = viewTracker
        self.groupTracker = groupTracker
    }
    
    deinit {
        runLoopObserver?.stop()
    }
    
    public func add(to runLoop: RunLoop) {
        runLoopObserver = RunLoopObserver(runLoop: runLoop) { [weak self, unowned runLoop] in
            self?.scheduleTimerIfNeeded(in: runLoop)
        }

        runLoopObserver?.start()
    }
    
    private func scheduleTimerIfNeeded(in runLoop: RunLoop) {
        guard !timerScheduled else {
            return
        }
        
        timerScheduled = true
        
        let timer = Foundation.Timer(timeInterval: 0.1, repeats: false) { [weak self] _ in
            self?.timerScheduled = false
            self?.checkViews()
        }
        runLoop.add(timer, forMode: .common)
    }
    
    private func checkViews() {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            assertionFailure("No key window")
            return
        }
        
        var hasher = ViewHasher()
        hasher.hash(keyWindow)
        let hash = hasher.hash
        
        guard hash != previousHash else {
            return
        }
        
        previousHash = hash
        
        var newShownViewIdentifiers: Set<AnyHashable> = []
        var newShownGroupIdentifiers: Set<AnyHashable> = []
        let screenMap = ScreenMap()
        
        checkView(
            keyWindow,
            screenMap: screenMap,
            newShownViewIdentifiers: &newShownViewIdentifiers,
            newShownGroupIdentifiers: &newShownGroupIdentifiers
        )
        
        shownViewIdentifiers = newShownViewIdentifiers
        shownGroupIdentifiers = newShownGroupIdentifiers
    }
    
    private func checkView(
        _ view: UIView,
        screenMap: ScreenMap,
        newShownViewIdentifiers: inout Set<AnyHashable>,
        newShownGroupIdentifiers: inout Set<AnyHashable>
    ) {
        guard view.isVisibleByAlpha else {
            return
        }
        
        defer {
            screenMap.insert(view.trackableFrame)
        }
        
        if let trackableView = view as? TrackableView {
            trackView(
                trackableView,
                screenMap: screenMap,
                newShownViewIdentifiers: &newShownViewIdentifiers,
                newShownGroupIdentifiers: &newShownGroupIdentifiers
            )
            return
        }
        
        view.subviews.reversed().forEach {
            checkView(
                $0,
                screenMap: screenMap,
                newShownViewIdentifiers: &newShownViewIdentifiers,
                newShownGroupIdentifiers: &newShownGroupIdentifiers
            )
        }
    }
    
    private func trackView(
        _ view: TrackableView,
        screenMap: ScreenMap,
        newShownViewIdentifiers: inout Set<AnyHashable>,
        newShownGroupIdentifiers: inout Set<AnyHashable>
    ) {
        let isVisible = view.geometricVisibilityPercentage >= threshold
        && (1 - screenMap.overlap(with: view.trackableFrame)) >= threshold
        
        guard isVisible else {
            return
        }
        
        if !shownViewIdentifiers.contains(view.identifier) {
            viewTracker(view)
        }
        
        view.groupIdentifiers.forEach {
            if !shownGroupIdentifiers.contains($0), !newShownGroupIdentifiers.contains($0) {
                groupTracker($0)
            }
        }
        
        newShownViewIdentifiers.insert(view.identifier)
        newShownGroupIdentifiers.formUnion(view.groupIdentifiers)
    }
}
