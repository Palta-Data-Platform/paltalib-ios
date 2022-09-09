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
        action: viewModel.changeContext
    )
    
    private lazy var loadTestButton = Button(
        title: "Load test",
        color: .systemRed,
        action: viewModel.loadTest
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
        view.addSubview(testLogButton)
        
        buttonsStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
}
