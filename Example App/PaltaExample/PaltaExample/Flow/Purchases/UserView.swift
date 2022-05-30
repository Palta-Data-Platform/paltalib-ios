//
//  UserView.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 30/05/2022.
//

import Foundation
import UIKit
import Combine

protocol UserViewModel: AnyObject {
    var statePublisher: AnyPublisher<UserView.State, Never> { get }
    
    func onButtonTap(_ login: String?)
}

final class UserView: UIView {
    internal
    
    enum State {
        case loggedIn(String)
        case loggedOut
    }
    
    private let viewModel: UserViewModel
    
    private let field = UITextField().do {
        $0.placeholder = "00000000-0000-0000-0000-000000000000"
        $0.borderStyle = .roundedRect
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var button = UIButton(type: .custom).do {
        $0.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [field, button]).do {
        $0.axis = .horizontal
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.spacing = 4
    }
    
    private var cancels: Set<AnyCancellable> = []

    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate(
            [
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                heightAnchor.constraint(equalToConstant: 44)
            ]
        )
    }
    
    private func setupBindings() {
        viewModel.statePublisher
            .sink { [unowned self] state in
                apply(state)
            }
            .store(in: &cancels)
    }
    
    private func apply(_ state: State) {
        switch state {
        case .loggedIn(let login):
            field.text = login
            field.isEnabled = false
            button.setTitle("Log Out", for: .normal)
        case .loggedOut:
            field.text = nil
            field.isEnabled = true
            button.setTitle("Log In", for: .normal)
        }
    }
    
    @objc
    private func onButtonTap() {
        viewModel.onButtonTap(field.text)
    }
}
