//
//  AvailableFeaturesViewController.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 05/10/2022.
//

import UIKit
import Combine

final class AvailableFeaturesViewController: UIViewController {
    private var cancels: Set<AnyCancellable> = []
    
    private let viewModel = AvailableFeaturesViewModel()
    
    private lazy var tableView = UITableView().do {
        $0.delegate = self
        $0.dataSource = self
        $0.rowHeight = UITableView.automaticDimension
        $0.allowsSelection = false
        $0.register(AvailableFeatureCell.self, forCellReuseIdentifier: "Feature")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onViewWillAppear()
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

extension AvailableFeaturesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Feature", for: indexPath) as! AvailableFeatureCell
        cell.item = viewModel.items[indexPath.row]
        
        return cell
    }
}
