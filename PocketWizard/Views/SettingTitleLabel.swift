//
//  SettingTitleLabel.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/12/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class SettingTitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont(name: "Arial-BoldMT", size: 24)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        font = UIFont(name: "Arial-BoldMT", size: 24)
    }
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                textColor = self.textColor.withAlphaComponent(1.0)
            } else {
                textColor = self.textColor.withAlphaComponent(0.8)
            }
        }
    }
}
