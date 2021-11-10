import UIKit

class MainViewController: UIViewController {
    
    private let viewModel: MainViewModelInterface
    
    init(viewModel: MainViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let logsTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 17, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.systemBlue.cgColor
        textView.layer.borderWidth = 2.0
        textView.layer.cornerRadius = 16
        return textView
    }()
    
    private lazy var testLogButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log test event", for: .normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 2.0
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(logEvent), for: .touchUpInside)
        return button
    }()
    
    private lazy var addTargetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add target", for: .normal)
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.layer.borderWidth = 2.0
        button.setTitleColor(.systemGreen, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(pushAddTargetScreen), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        configureTestButton()
        configureAddTargetButton()
        configureTextView()
    }
    
    private func configureTextView() {
        view.addSubview(logsTextView)
        NSLayoutConstraint.activate([logsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                                     logsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                                     logsTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -32),
                                     logsTextView.bottomAnchor.constraint(equalTo: addTargetButton.topAnchor, constant: -32)])

    }
    
    private func configureTestButton() {
        view.addSubview(testLogButton)
        NSLayoutConstraint.activate([testLogButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                                     testLogButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                                     testLogButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
                                     testLogButton.heightAnchor.constraint(equalToConstant: 60)])
    }
    
    private func configureAddTargetButton() {
        view.addSubview(addTargetButton)
        NSLayoutConstraint.activate([addTargetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                                     addTargetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                                     addTargetButton.bottomAnchor.constraint(equalTo: testLogButton.topAnchor, constant: -32),
                                     addTargetButton.heightAnchor.constraint(equalToConstant: 60)])
    }
    
    @objc private func logEvent() {
        viewModel.logTestEvent()
    }
    
    @objc private func pushAddTargetScreen() {
        let viewModel = AddTargetViewModel()
        let controller = AddTargetViewController(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }

}
