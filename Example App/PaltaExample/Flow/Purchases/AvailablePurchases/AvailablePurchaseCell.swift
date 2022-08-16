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
    var item: AvailablePurchasesViewModel.Item? {
        didSet {
            update()
        }
    }
    
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
            $0.trailing.equalToSuperview().inset(16)
            $0.leading.greaterThanOrEqualTo(nameLabel.snp.trailing)
        }
    }
    
    private func update() {
        nameLabel.text = item?.name
        periodLabel.text = item?.period
        priceLabel.text = item?.price
    }
}
