//
//  PaidfeaturesTests.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import XCTest
@testable import PaltaLibPayments

final class PaidfeaturesTests: XCTestCase {
    func testEmptyInit() {
        XCTAssertEqual(PaidFeatures(), PaidFeatures(features: []))
    }
    
    func testMerge1() {
        let s1 = [
            PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: 1), endDate: nil),
            PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date()),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil),
            PaidFeature(name: "Name 3", startDate: Date(timeIntervalSinceNow: -80), endDate: Date())
        ]
        
        let features1 = PaidFeatures(features: s1)
        
        let s2 = [
            PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: 10), endDate: nil),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: -98), endDate: Date()),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: 5), endDate: nil),
            PaidFeature(name: "Name 4", startDate: Date(timeIntervalSinceNow: -88), endDate: Date())
        ]
        
        var features2 = PaidFeatures(features: s2)
        
        let expectedMerged = PaidFeatures(
            features: s1 + s2
        )
        
        features2.merge(with: features1)
        
        XCTAssertEqual(features2, expectedMerged)
    }
    
    func testMerge2() {
        let s1 = [
            PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: 1), endDate: nil),
            PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date()),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: -80), endDate: Date())
        ]
        
        let features1 = PaidFeatures(features: s1)
        
        let s2 =  [
            PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: 10), endDate: nil),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: -98), endDate: Date()),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: 5), endDate: nil),
            PaidFeature(name: "Name 3", startDate: Date(timeIntervalSinceNow: -88), endDate: Date())
        ]
        
        let features2 = PaidFeatures(features: s2)
        
        let expectedMerged = PaidFeatures(
            features: s1 + s2
        )
        
        XCTAssertEqual(features1.merged(with: features2), expectedMerged)
    }
    
    func testHasActiveSubscriptionTrue() {
        let features = PaidFeatures(
            features: [
                PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: -1), endDate: nil),
                PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date(timeIntervalSinceNow: -3)),
                PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil)
            ]
        )
        
        XCTAssert(features.hasActiveFeature(with: "Name 1"))
    }
    
    func testHasActiveSubscriptionFalse() {
        let features = PaidFeatures(
            features: [
                PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: 1), endDate: nil),
                PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date(timeIntervalSinceNow: -3)),
                PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil)
            ]
        )
        
        XCTAssertFalse(features.hasActiveFeature(with: "Name 2"))
    }
    
    func testHasActiveSubscriptionNoFeature() {
        let features = PaidFeatures(
            features: [
                PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: 1), endDate: nil),
                PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date(timeIntervalSinceNow: -3)),
                PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil)
            ]
        )
        
        XCTAssertFalse(features.hasActiveFeature(with: "Name 3"))
    }
    
    func testToArray() {
        let featureset: Set<PaidFeature> = [
            PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: 1), endDate: nil),
            PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: -8), endDate: Date()),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: 55), endDate: nil),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: -80), endDate: Date()),
            PaidFeature(name: "Name 1", startDate: Date(timeIntervalSinceNow: 10), endDate: nil),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: -98), endDate: Date()),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSinceNow: 5), endDate: nil),
            PaidFeature(name: "Name 3", startDate: Date(timeIntervalSinceNow: -88), endDate: Date())
        ]
        
        let features = PaidFeatures(features: Array(featureset))
        
        XCTAssertEqual(Set(features.features), featureset)
    }
    
    func testSubscript() {
        let features = PaidFeatures(
            features: [
                PaidFeature(name: "Name 1", startDate: Date(timeIntervalSince1970: 1), endDate: nil),
                PaidFeature(name: "Name 1", startDate: Date(timeIntervalSince1970: -8), endDate: Date(timeIntervalSince1970: 0)),
                PaidFeature(name: "Name 2", startDate: Date(timeIntervalSince1970: 55), endDate: nil),
                PaidFeature(name: "Name 2", startDate: Date(timeIntervalSince1970: -80), endDate: Date(timeIntervalSince1970: 0)),
                PaidFeature(name: "Name 1", startDate: Date(timeIntervalSince1970: 10), endDate: nil),
                PaidFeature(name: "Name 2", startDate: Date(timeIntervalSince1970: -98), endDate: Date(timeIntervalSince1970: 0)),
                PaidFeature(name: "Name 2", startDate: Date(timeIntervalSince1970: 5), endDate: nil),
                PaidFeature(name: "Name 3", startDate: Date(timeIntervalSince1970: -88), endDate: Date(timeIntervalSince1970: 0))
            ]
        )
        
        let featureset = Set(features["Name 2"])
        
        let expectedfeatureset: Set<PaidFeature> = [
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSince1970: 55), endDate: nil),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSince1970: -80), endDate: Date(timeIntervalSince1970: 0)),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSince1970: -98), endDate: Date(timeIntervalSince1970: 0)),
            PaidFeature(name: "Name 2", startDate: Date(timeIntervalSince1970: 5), endDate: nil)
        ]
        
        XCTAssertEqual(featureset, expectedfeatureset)
    }
}
