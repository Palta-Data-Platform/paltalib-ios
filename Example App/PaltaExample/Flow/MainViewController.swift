//
//  MainViewController.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 03.05.2022.
//

import Foundation
import UIKit

final class MainViewController: UIViewController {
    private lazy var analyticsButton = Button(
        title: "Analytics",
        color: .systemGreen
    ) { [weak self] in
        self?.navigationController?.pushViewController(
            AnalyticsViewController(viewModel: AnalyticsViewModel()),
            animated: true
        )
    }

    private lazy var paymentsButton = Button(
        title: "Payments",
        color: .systemMint
    ) { [weak self] in
        self?.navigationController?.pushViewController(
            PurchasesViewController(viewModel: PurchasesViewModel()),
            animated: true
        )
    }
    
    private lazy var environmentButton = Button(
        title: "Change environment",
        color: .systemRed
    ) { [weak self] in
        self?.navigationController?.pushViewController(
            EnvironmentSetupViewController(),
            animated: true
        )
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [analyticsButton, paymentsButton, environmentButton])
        stackView.axis = .vertical
        stackView.spacing = 64
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
}
