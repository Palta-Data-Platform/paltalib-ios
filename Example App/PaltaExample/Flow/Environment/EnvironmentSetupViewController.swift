//
//  EnvironmentSetupViewController.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 28/10/2022.
//

import Combine
import UIKit

final class EnvironmentSetupViewController: UIViewController {
    private let viewModel = EnvironmentSetupViewModel()
    
    private lazy var analyticsHostView = FieldView().do {
        $0.label.text = "Analytics host"
        $0.textField.placeholder = viewModel.analyticsHostPlaceholder
        $0.textField.text = viewModel.analyticsHost
        $0.textField.returnKeyType = .next
        $0.textField.delegate = self
    }
    
    private lazy var analyticsKeyView = FieldView().do {
        $0.label.text = "Analytics API key"
        $0.textField.placeholder = viewModel.analyticsKeyPlaceholder
        $0.textField.text = viewModel.analyticsKey
        $0.textField.returnKeyType = .next
        $0.textField.delegate = self
    }
    
    private lazy var paymentsHostView = FieldView().do {
        $0.label.text = "Payments host"
        $0.textField.placeholder = viewModel.paymentsHostPlaceholder
        $0.textField.text = viewModel.paymentsHost
        $0.textField.returnKeyType = .next
        $0.textField.delegate = self
    }
    
    private lazy var paymentsKeyView = FieldView().do {
        $0.label.text = "Payments API key"
        $0.textField.placeholder = viewModel.paymentsKeyPlaceholder
        $0.textField.text = viewModel.paymentsKey
        $0.textField.returnKeyType = .done
        $0.textField.delegate = self
    }
    
    private lazy var stackView = UIStackView(arrangedSubviews: [analyticsHostView, analyticsKeyView, paymentsHostView, paymentsKeyView]).do {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .fill
    }
    
    private lazy var saveButton = Button(title: "Save and quit", color: .systemGreen) { [viewModel] in
        viewModel.commit()
    }
    
    private var cancels: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        view.addSubview(saveButton)
        
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-48)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(stackView)
            $0.top.equalTo(stackView.snp.bottom).offset(32)
        }
        
        viewModel.$isReady
            .sink { [saveButton] isReady in
                saveButton.isEnabled = isReady
            }
            .store(in: &cancels)
        
        analyticsHostView.textField.textPublisher.assign(to: &viewModel.$analyticsHost)
        analyticsKeyView.textField.textPublisher.assign(to: &viewModel.$analyticsKey)
        paymentsHostView.textField.textPublisher.assign(to: &viewModel.$paymentsHost)
        paymentsKeyView.textField.textPublisher.assign(to: &viewModel.$paymentsKey)
    }
}

private class FieldView: UIView {
    let label = UILabel().do {
        $0.font = .systemFont(ofSize: 20)
    }
    
    let textField = UITextField().do {
        $0.borderStyle = .roundedRect
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.keyboardType = .URL
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        addSubview(textField)
        
        label.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EnvironmentSetupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.superview {
        case analyticsHostView:
            analyticsKeyView.textField.becomeFirstResponder()
        case analyticsKeyView:
            paymentsHostView.textField.becomeFirstResponder()
        case paymentsHostView:
            paymentsKeyView.textField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

extension UITextField {
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map {
                ($0.object as? UITextField)?.text
            }
            .eraseToAnyPublisher()
    }
}
