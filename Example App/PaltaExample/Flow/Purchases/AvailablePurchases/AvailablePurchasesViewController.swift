//
//  AvailablePurchasesViewController.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 16/08/2022.
//

import UIKit
import Combine

final class AvailablePurchasesViewController: UIViewController {
    private var cancels: Set<AnyCancellable> = []
    
    private let viewModel = AvailablePurchasesViewModel()
    
    private lazy var tableView = UITableView().do {
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.allowsSelection = false
        $0.register(AvailablePurchaseCell.self, forCellReuseIdentifier: "Purchase")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBindings()
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel.$items
            .sink { [tableView] _ in
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
            .store(in: &cancels)
    }
}

extension AvailablePurchasesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(viewModel.items.count)
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Purchase", for: indexPath) as! AvailablePurchaseCell
        cell.item = viewModel.items[indexPath.row]
        return cell
    }
}
