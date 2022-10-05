//
//  AvailableFeaturesViewModel.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 05/10/2022.
//

import Foundation
import PaltaLibPurchases

final class AvailableFeaturesViewModel {
    struct Item: Equatable {
        let name: String
        let period: String
        let subscribtionId: String?
    }
    
    @Published
    private(set) var items: [Item] = []
    
    func onViewWillAppear() {
        items = []
        fetchFeatures()
    }
    
    private func fetchFeatures() {
        PaltaPurchases.instance.getPaidFeatures { [weak self] result in
            switch result {
            case .success(let features):
                self?.mapFeatures(features)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func mapFeatures(_ features: PaidFeatures) {
        items = features.features.map{ feature in
            Item(
                name: feature.name,
                period: "Valid until: \(feature.endDate?.description ?? "Forever")",
                subscribtionId: nil
            )
        }
    }
}
