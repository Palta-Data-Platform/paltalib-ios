//
//  Button.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 03.05.2022.
//

import UIKit

final class Button: UIButton {
    private static let pressedBackground = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
        UIColor.systemGray4.setFill()
        context.cgContext.fill(.infinite)
    }
    private let action: () -> Void

    init(title: String, color: UIColor, action: @escaping () -> Void) {
        self.action = action

        super.init(frame: .zero)

        setTitle(title, for: .normal)
        layer.borderColor = color.cgColor
        layer.borderWidth = 2.0
        setTitleColor(color, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        clipsToBounds = true
        addTarget(self, action: #selector(onAction), for: .touchUpInside)

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
