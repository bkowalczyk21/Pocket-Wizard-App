//
//  ZoneButton.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/11/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class ZoneButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        layer.cornerRadius = 25
        setTitleColor(.lightText, for: .disabled)
        setTitleColor(.systemGreen, for: .normal)
        setTitleColor(.white, for: .selected)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        layer.cornerRadius = 25
        setTitleColor(.lightText, for: .disabled)
        setTitleColor(.systemGreen, for: .normal)
        setTitleColor(.white, for: .selected)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .systemGreen
            } else {
                backgroundColor = .darkGray
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                if isSelected {
                    backgroundColor = .systemGreen
                } else {
                    backgroundColor = .darkGray
                }
            } else {
                if isSelected {
                    backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
                } else {
                    backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
                }
            }
        }
    }
}
