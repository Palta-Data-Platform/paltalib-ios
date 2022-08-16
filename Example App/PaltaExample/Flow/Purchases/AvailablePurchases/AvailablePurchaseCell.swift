//
//  AvailablePurchaseCell.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 16/08/2022.
//

import Foundation
import UIKit
import PaltaLibCore
import SnapKit

final class AvailablePurchaseCell: UITableViewCell {
    typealias Item = AvailablePurchasesViewModel.Item
    
    var item: Item? {
        didSet {
            update()
        }
    }
    
    var buyHandler: ((Item) -> Void)?
    
    private let nameLabel = UILabel().do {
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 17, weight: .regular)
    }
    
    private let periodLabel = UILabel().do {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .darkGray
    }
    
    private let priceLabel = UILabel().do {
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.textAlignment = .right
    }
    
    private lazy var buyButton = Button(title: "Buy", color: .systemBlue) { [weak self] in
        guard let self = self, let item = self.item else {
            return
        }
        self.buyHandler?(item)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupLayout() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(periodLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(buyButton)
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalToSuperview().inset(8)
        }
        
        periodLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(nameLabel)
            $0.bottom.equalToSuperview().inset(8)
        }
        
        priceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(nameLabel.snp.trailing)
        }
        
        buyButton.snp.makeConstraints {
            $0.height.equalTo(32)
            $0.width.equalTo(44)
            $0.centerY.equalTo(priceLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.leading.equalTo(priceLabel.snp.trailing).offset(8)
        }
    }
    
    private func update() {
        nameLabel.text = item?.name
        periodLabel.text = item?.period
        priceLabel.text = item?.price
    }
}
