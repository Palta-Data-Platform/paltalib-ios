import UIKit

class MainViewController: UIViewController {
    
    private let testLogButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log test event", for: .normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 2.0
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let addTargetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add target", for: .normal)
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.layer.borderWidth = 2.0
        button.setTitleColor(.systemGreen, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
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

}
