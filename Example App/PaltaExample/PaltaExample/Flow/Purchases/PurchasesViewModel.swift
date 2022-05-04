//
//  PurchasesViewModel.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 03.05.2022.
//

import Foundation
import Combine

protocol PurchasesViewModelInterface {
    var subscriptionStatePublisher: AnyPublisher<String?, Never> { get }

    var isSubscribeButtonActivePublisher: AnyPublisher<Bool, Never> { get }

    func subscribe()
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
        $state
            .map {
                switch $0 {
                case .subscribed:
                    return false
                case .notSubscribed:
                    return true
                }
            }
            .eraseToAnyPublisher()
    }

    @Published
    private var state: State = .notSubscribed

    func subscribe() {
    }
}
