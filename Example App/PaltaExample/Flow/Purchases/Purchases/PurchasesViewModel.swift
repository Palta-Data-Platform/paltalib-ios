//
//  PurchasesViewModel.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 03.05.2022.
//

import Foundation
import Combine
import PaltaLibPurchases

protocol PurchasesViewModelInterface {
    var subscriptionStatePublisher: AnyPublisher<String?, Never> { get }

    var isSubscribeButtonActivePublisher: AnyPublisher<Bool, Never> { get }
    var isBuyLifetimeButtonActivePublisher: AnyPublisher<Bool, Never> { get }
    var isBuyPeriodButtonActivePublisher: AnyPublisher<Bool, Never> { get }
    var isButtonActive: AnyPublisher<Bool, Never> { get }

    func subscribe()
    func buyLifetime()
    func buyPeriod()
}

final class PurchasesViewModel: PurchasesViewModelInterface {
    private enum State {
        case subscribed
        case notSubscribed
    }

    var subscriptionStatePublisher: AnyPublisher<String?, Never> {
        $state
            .map { (state: State) -> String in
                switch state {
                case .subscribed:
                    return "Active"
                case .notSubscribed:
                    return "Not subscribed"
                }
            }
            .map { "Subscription state: \($0)" }
            .eraseToAnyPublisher()
    }

    var isSubscribeButtonActivePublisher: AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest(isButtonActive, $subscriptionProduct)
            .map { $0 && $1 != nil }
            .eraseToAnyPublisher()
    }
    
    var isBuyPeriodButtonActivePublisher: AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest(isButtonActive, $periodProduct)
            .map { $0 && $1 != nil }
            .eraseToAnyPublisher()
    }
    
    var isBuyLifetimeButtonActivePublisher: AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest(isButtonActive, $lifetimeProduct)
            .map { $0 && $1 != nil }
            .eraseToAnyPublisher()
    }
    
    var isButtonActive: AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest($state, $userId)
            .map {
                switch ($0, $1) {
                case (.subscribed, _), (.notSubscribed, nil):
                    return false
                case (.notSubscribed, _?):
                    return true
                }
            }
            .eraseToAnyPublisher()
    }

    @Published
    private var state: State = .notSubscribed
    
    @Published
    private var userId: UUID?
    
    @Published
    private var subscriptionProduct: Product?
    @Published
    private var lifetimeProduct: Product?
    @Published
    private var periodProduct: Product?
    
    private var cancels: Set<AnyCancellable> = []
    
    init() {
        setupBindings()
    }

    func subscribe() {
        guard let subscriptionProduct = subscriptionProduct else {
            return
        }

        PaltaPurchases.instance.purchase(subscriptionProduct, with: nil) { [weak self] result in
            switch result {
            case .success(let purchase):
                self?.update(with: purchase.paidFeatures)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func buyPeriod() {
        guard let periodProduct = periodProduct else {
            return
        }

        PaltaPurchases.instance.purchase(periodProduct, with: nil) { [weak self] result in
            switch result {
            case .success(let purchase):
                self?.update(with: purchase.paidFeatures)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func buyLifetime() {
        guard let lifetimeProduct = lifetimeProduct else {
            return
        }

        PaltaPurchases.instance.purchase(lifetimeProduct, with: nil) { [weak self] result in
            switch result {
            case .success(let purchase):
                self?.update(with: purchase.paidFeatures)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setupBindings() {
        $userId
            .sink { [unowned self] userId in
                if let userId = userId {
                    getPurchases(with: userId)
                } else {
                    logout()
                }
            }
            .store(in: &cancels)
    }
    
    private func getPurchases(with userId: UUID) {
        PaltaPurchases.instance.logIn(appUserId: .uuid(userId)) { _ in
            PaltaPurchases.instance.getProducts(with: ["com.palta.brain.demo.paidfeature"]) { [weak self] result in
                switch result {
                case .success(let products):
                    print("EBUNAAA \(products)")
                    self?.subscriptionProduct = products.first(where: { $0.productType == .autoRenewableSubscription })
                    self?.lifetimeProduct = products.first(where: { $0.productType == .nonConsumable })
                    self?.periodProduct = products.first(where: { $0.productType == .nonRenewableSubscription })
                case .failure(let error):
                    print("EBUNAAA \(error)")
                    print(error)
                }
            }
        }
        
        PaltaPurchases.instance.getPaidFeatures { [weak self] result in
            switch result {
            case .success(let features):
                print(features)
                self?.update(with: features)
                
            case .failure(let error):
                print(error)
            }
        }
        
        print("EBUNAAA")
        
        
    }
    
    private func update(with paidFeatures: PaidFeatures) {
        state = paidFeatures.hasActiveFeature(with: "prisma_premium") ? .subscribed : .notSubscribed
    }
    
    private func logout() {
        PaltaPurchases.instance.logOut()
        state = .notSubscribed
    }
}

extension PurchasesViewModel: UserViewModel {
    var statePublisher: AnyPublisher<UserView.State, Never> {
        $userId
            .map {
                $0.map { .loggedIn($0.uuidString) } ?? .loggedOut
            }
            .eraseToAnyPublisher()
    }
    
    func onButtonTap(_ login: String?) {
        if userId != nil {
            userId = nil
        } else if let userId = login.flatMap(UUID.init) {
            self.userId = userId
        }
    }
}
