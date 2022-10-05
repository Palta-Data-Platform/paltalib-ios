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
    var isButtonActive: AnyPublisher<Bool, Never> { get }
    
    func onViewWillAppear()
}

final class PurchasesViewModel: PurchasesViewModelInterface {
    private enum State {
        case subscribed
        case notSubscribed
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
    
    func onViewWillAppear() {
        if let userId = userId {
            getPurchases(with: userId)
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
        }
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
    
    func onLoginTap(_ login: String?) {
        if userId != nil {
            userId = nil
        } else if let userId = login.flatMap(UUID.init) {
            self.userId = userId
        }
    }
    
    func onGenerateTap() {
        onLoginTap(UUID().uuidString)
    }
}
