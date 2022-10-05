//
//  AvailablePurchasesViewController.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 16/08/2022.
//

import UIKit
import Combine
import MBProgressHUD

final class AvailablePurchasesViewController: UIViewController {
    private var cancels: Set<AnyCancellable> = []
    
    private let viewModel = AvailablePurchasesViewModel()
    
    private lazy var progressHud = MBProgressHUD(view: view)
    
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
        
        viewModel.$operationInProgress
            .filter { $0 }
            .sink { [view] _ in
                MBProgressHUD.showAdded(to: view!, animated: true)
            }
            .store(in: &cancels)
        
        viewModel.$operationInProgress
            .filter { !$0 }
            .sink { [view] _ in
                MBProgressHUD.hide(for: view!, animated: true)
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
        
        cell.buyHandler = { [unowned self] in
            navigationController?.pushViewController(PurchaseDebugViewController(product: $0.product), animated: true)
        }
        
        return cell
    }
}
