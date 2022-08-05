//
//  Button.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 03.05.2022.
//

import UIKit

private extension UIImage {
    static func image(of color: UIColor) -> UIImage {
        let bounds = CGRect(origin: .zero, size: .init(width: 1, height: 1))
        return UIGraphicsImageRenderer(bounds: bounds).image { context in
            color.setFill()
            context.cgContext.fill(bounds)
        }
    }
}

final class Button: UIButton {
    private static let pressedBackground = UIImage.image(of: .systemGray3)
    
    private let action: () -> Void

    init(title: String, color: UIColor, action: @escaping () -> Void) {
        self.action = action

        super.init(frame: .zero)

        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        clipsToBounds = true
        addTarget(self, action: #selector(onAction), for: .touchUpInside)

        setBackgroundImage(.image(of: color), for: .normal)
        setBackgroundImage(.image(of: color.withAlphaComponent(0.3)), for: .disabled)
        setBackgroundImage(Button.pressedBackground, for: .highlighted)

        heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func onAction() {
        action()
    }
}
