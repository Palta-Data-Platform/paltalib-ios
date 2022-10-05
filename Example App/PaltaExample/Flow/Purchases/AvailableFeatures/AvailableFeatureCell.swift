//
//  AvailableFeatureCell.swift
//  PaltaExample
//
//  Created by Vyacheslav Beltyukov on 05/10/2022.
//

import Foundation
import UIKit
import PaltaLibCore
import SnapKit

final class AvailableFeatureCell: UITableViewCell {
    typealias Item = AvailableFeaturesViewModel.Item
    
    var item: Item? {
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
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalToSuperview().inset(8)
        }
        
        periodLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(nameLabel)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func update() {
        nameLabel.text = item?.name
        periodLabel.text = item?.period
    }
}
