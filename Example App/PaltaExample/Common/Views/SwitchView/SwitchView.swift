import UIKit

class SwitchView: UIView {
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    

    init(text: String, isOn: Bool) {
        super.init(frame: .zero)
        textLabel.text = text
        switcher.isOn = isOn
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        configureTextLabel()
        configureSwitcher()
    }
    
    private func configureTextLabel() {
        addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4)])
    }
    
    private func configureSwitcher() {
        addSubview(switcher)
        NSLayoutConstraint.activate([
            switcher.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)])
    }

}
