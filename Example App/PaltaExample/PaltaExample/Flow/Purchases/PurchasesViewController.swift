//
//  PurchasesViewController.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 03.05.2022.
//

import UIKit
import Combine

final class PurchasesViewController: UIViewController {
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

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stateLabel, subscribeButton])
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
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
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
    }
}
