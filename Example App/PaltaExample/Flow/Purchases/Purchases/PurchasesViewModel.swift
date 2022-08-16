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
    var isButtonActive: AnyPublisher<Bool, Never> { get }
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
    
    private var cancels: Set<AnyCancellable> = []
    
    init() {
        setupBindings()
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
