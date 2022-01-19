import UIKit
import PaltaLib

class AddTargetViewController: UIViewController {
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 2.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = 16
        textField.placeholder = "Target name"
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.keyboardType = .default
        return textField
    }()
    
    private let eventMaxCountTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 2.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = 16
        textField.placeholder = "Events max count"
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let eventUploadMaxBatchSizeTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 2.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = 16
        textField.placeholder = "Upload max batch size"
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let eventUploadPeriodSecondsTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 2.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = 16
        textField.placeholder = "Upload period, sec"
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let eventUploadThresholdTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 2.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = 16
        textField.placeholder = "Upload threshold"
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let minTimeBetweenSessionsMillisTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 2.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = 16
        textField.placeholder = "Min time between sessions"
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let urlTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 2.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = 16
        textField.placeholder = "Server URL"
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.keyboardType = .default
        return textField
    }()
    
    private let trackingSwitchView = SwitchView(text: "Tracking session events", isOn: false)

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(eventMaxCountTextField)
        stackView.addArrangedSubview(eventUploadMaxBatchSizeTextField)
        stackView.addArrangedSubview(eventUploadPeriodSecondsTextField)
        stackView.addArrangedSubview(eventUploadThresholdTextField)
        stackView.addArrangedSubview(minTimeBetweenSessionsMillisTextField)
        stackView.addArrangedSubview(urlTextField)
        stackView.addArrangedSubview(trackingSwitchView)
        return stackView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add target", for: .normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 2.0
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addTarget), for: .touchUpInside)
        return button
    }()
    
    private let viewModel: AddTargetViewModelInterface
    
    init(viewModel: AddTargetViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        title = "Add target"
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        configureStackView()
        configureAddButton()
    }
    
    private func configureStackView() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                                     stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                                     stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)])
    }
    
    private func configureAddButton() {
        view.addSubview(addButton)
        NSLayoutConstraint.activate([addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                                     addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                                     addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                                     addButton.heightAnchor.constraint(equalToConstant: 60)])
    }
    
    @objc private func addTarget() {
        guard let name = nameTextField.text,
              let eventMaxCount = Int(eventMaxCountTextField.text ?? ""),
              let eventUploadMaxBatchSize = Int(eventUploadMaxBatchSizeTextField.text ?? ""),
              let eventUploadPeriodSeconds = Int(eventUploadPeriodSecondsTextField.text ?? ""),
              let eventUploadThreshold = Int(eventUploadThresholdTextField.text ?? ""),
              let minTimeBetweenSessions = Int(minTimeBetweenSessionsMillisTextField.text ?? "") else {
                  return
              }
        
        let settings = ConfigSettings(eventUploadThreshold: eventUploadThreshold,
                                      eventUploadMaxBatchSize: eventUploadMaxBatchSize,
                                      eventMaxCount: eventMaxCount,
                                      eventUploadPeriodSeconds: eventUploadPeriodSeconds,
                                      minTimeBetweenSessionsMillis: minTimeBetweenSessions,
                                      trackingSessionEvents: false)
        
        PaltaAnalytics.instance.addConfigTarget(.init(name: name, settings: settings, url: urlTextField.text))
        navigationController?.popViewController(animated: true)
    }
}
