//
//  PurchaseDebugViewController.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 09/09/2022.
//

import Foundation
import PaltaLibPurchases
import Combine

final class PurchaseDebugViewController: UIViewController {
    private lazy var okLabel = UILabel().do {
        $0.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        $0.textColor = .systemGreen
        $0.text = "OK"
        $0.isHidden = true
        $0.textAlignment = .center
    }
    
    private lazy var failureLabel = UILabel().do {
        $0.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        $0.textColor = .systemRed
        $0.text = "Failure"
        $0.isHidden = true
        $0.textAlignment = .center
    }
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large).do {
        $0.hidesWhenStopped = true
    }
    
    private lazy var textView = UITextView()
    
    private lazy var stackView = UIStackView(arrangedSubviews: [okLabel, activityIndicator, failureLabel, textView]).do {
        $0.axis = .vertical
        $0.spacing = 24
        $0.distribution = .fill
    }
    
    @Published
    private var logs: String = ""
    
    private var cancels: Set<AnyCancellable> = []
    
    private let product: Product
    
    init(product: Product) {
        self.product = product
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        $logs
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [textView] in
                textView.text = $0
            })
            .store(in: &cancels)
        
        activityIndicator.startAnimating()
        
        PaltaPurchases.instance.purchase2(product, stages: { [unowned self] in
            logs += "\n\n\($0)"
        }) { [unowned self] result in
            switch result {
            case .success:
                okLabel.isHidden = false
            case .failure:
                failureLabel.isHidden = false
            }
            
            activityIndicator.stopAnimating()
        }
    }
}
