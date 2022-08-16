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
        
        fileprivate let product: Product
    }
    
    private let productIdentifiers: [String] = [
        "com.palta.brain.demo.paidfeature",
        "nonrensubsc",
        "com.paltabrain.payments.test1"
    ]
    
    @Published
    private(set) var items: [Item] = []
    
    init() {
        fetchProducts()
    }
    
    func buy(_ item: Item) {
        PaltaPurchases.instance.purchase(item.product, with: nil) { [weak self] result in
            switch result {
            case .success:
                self?.items.removeAll(where: { $0 == item })
            case .failure(let error):
                print("Unable to purchase: \(error)")
            }
        }
    }
    
    private func fetchProducts() {
        PaltaPurchases.instance.getProducts(with: productIdentifiers) { [weak self] result in
            switch result {
            case .success(let products):
                self?.mapProducts(products)
            case .failure(let error):
                print("Unable to fetch products: \(error)")
            }
        }
    }
    
    private func mapProducts(_ products: Set<Product>) {
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
