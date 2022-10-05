//
//  AvailablePurchasesViewModel.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 16/08/2022.
//

import Foundation
import PaltaLibPurchases

final class AvailablePurchasesViewModel {
    struct Item: Equatable {
        let name: String
        let period: String
        let price: String
        
        let product: Product
    }
    
    @Published
    private(set) var operationInProgress = false
    
    @Published
    private(set) var items: [Item] = []
    
    func buy(_ item: Item) {
        operationInProgress = true
        
        PaltaPurchases.instance.purchase(item.product, with: nil) { [weak self] result in
            switch result {
            case .success:
                self?.items.removeAll(where: { $0 == item })
            case .failure(let error):
                print("Unable to purchase: \(error)")
            }

            self?.operationInProgress = false
        }
    }
    
    func onViewWillAppear() {
        items = []
        fetchProducts()
    }
    
    private func fetchProducts() {
        PaltaPurchases.instance.getShowcaseProducts { [weak self] result in
            switch result {
            case .success(let products):
                self?.mapProducts(products)
            case .failure(let error):
                print("Unable to fetch products: \(error)")
            }
        }
    }
    
    private func mapProducts(_ products: [Product]) {
        items = products.map {
            Item(
                name: $0.localizedTitle,
                period: $0.subscriptionPeriod.map { $0.displayTitle } ?? "Lifetime",
                price: $0.localizedPriceString,
                product: $0
            )
        }
    }
}

extension SubscriptionPeriod {
    var displayTitle: String {
        "\(value) \(unit)\(value > 1 ? "s" : "")"
    }
}
