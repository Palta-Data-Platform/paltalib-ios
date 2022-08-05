//
//  PurchasesViewController.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 03.05.2022.
//

import UIKit
import Combine

final class PurchasesViewController: UIViewController {
    private lazy var userView = UserView(viewModel: viewModel as! UserViewModel)

    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var subscribeButton = Button(
        title: "Subscribe",
        color: .systemMint,
        action: viewModel.subscribe
    )
    
    private lazy var buyLifetimeButton = Button(
        title: "Buy lifetime",
        color: .cyan,
        action: viewModel.buyLifetime
    )
    
    private lazy var buyPeriodButton = Button(
        title: "Buy period",
        color: .systemTeal,
        action: viewModel.buyPeriod
    )

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [userView, stateLabel, subscribeButton, buyLifetimeButton, buyPeriodButton]
        )
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 32
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var cancels: Set<AnyCancellable> = []

    private let viewModel: PurchasesViewModelInterface

    init(viewModel: PurchasesViewModelInterface) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32)
        ])
    }

    private func setupBindings() {
        viewModel.subscriptionStatePublisher
            .assign(to: \.text, on: stateLabel)
            .store(in: &cancels)

        viewModel.isSubscribeButtonActivePublisher
            .assign(to: \.isEnabled, on: subscribeButton)
            .store(in: &cancels)
        
        viewModel.isBuyLifetimeButtonActivePublisher
            .assign(to: \.isEnabled, on: buyLifetimeButton)
            .store(in: &cancels)
        
        viewModel.isBuyPeriodButtonActivePublisher
            .assign(to: \.isEnabled, on: buyPeriodButton)
            .store(in: &cancels)
    }
}
