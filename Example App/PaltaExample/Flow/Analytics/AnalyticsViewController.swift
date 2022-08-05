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
    
    private lazy var testLogButton = Button(
        title: "Log test event",
        color: .systemBlue,
        action: viewModel.logTestEvent
    )
    
    private lazy var changeContextButton = Button(
        title: "Change context",
        color: .systemBrown,
        action: viewModel.logTestEvent
    )
    
    private lazy var loadTestButton = Button(
        title: "Load test",
        color: .systemRed,
        action: viewModel.logTestEvent
    )
    
    private lazy var buttonsStack = UIStackView(arrangedSubviews: [testLogButton, changeContextButton, loadTestButton]).do {
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.spacing = 24
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        configureTestButton()
    }
    
    private func configureTestButton() {
        view.addSubview(buttonsStack)
        NSLayoutConstraint.activate([
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0)
        ])
    }
}
