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
    ) {

    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [analyticsButton, paymentsButton])
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

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32)
        ])
    }
}
