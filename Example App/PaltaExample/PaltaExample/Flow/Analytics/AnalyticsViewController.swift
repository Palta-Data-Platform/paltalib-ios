import UIKit

class AnalyticsViewController: UIViewController {
    
    private let viewModel: AnalyticsModelInterface
    
    init(viewModel: AnalyticsModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        configureTestButton()
    }
    
    private func configureTestButton() {
        view.addSubview(testLogButton)
        NSLayoutConstraint.activate([
            testLogButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            testLogButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            testLogButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0),
            testLogButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func logEvent() {
        viewModel.logTestEvent()
    }
}
