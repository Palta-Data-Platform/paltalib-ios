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

    private lazy var buyButton = Button(
        title: "Buy something",
        color: .systemMint
    ) { [unowned self] in
        navigationController?.pushViewController(
            AvailablePurchasesViewController(),
            animated: true
        )
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [userView, stateLabel, buyButton]
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
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(64)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func setupBindings() {
        viewModel.subscriptionStatePublisher
            .assign(to: \.text, on: stateLabel)
            .store(in: &cancels)

        viewModel.isButtonActive
            .assign(to: \.isEnabled, on: buyButton)
            .store(in: &cancels)
    }
}
