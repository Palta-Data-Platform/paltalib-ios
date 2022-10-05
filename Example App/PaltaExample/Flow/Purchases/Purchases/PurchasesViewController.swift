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

    private lazy var buyButton = Button(
        title: "Buy something",
        color: .systemMint
    ) { [unowned self] in
        navigationController?.pushViewController(
            AvailablePurchasesViewController(),
            animated: true
        )
    }
    
    private lazy var featuresButton = Button(
        title: "Check available features",
        color: .systemTeal
    ) { [unowned self] in
        navigationController?.pushViewController(
            AvailableFeaturesViewController(),
            animated: true
        )
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [userView, buyButton, featuresButton]
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onViewWillAppear()
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
        viewModel.isButtonActive
            .assign(to: \.isEnabled, on: buyButton)
            .store(in: &cancels)
        
        viewModel.isButtonActive
            .assign(to: \.isEnabled, on: featuresButton)
            .store(in: &cancels)
    }
}
