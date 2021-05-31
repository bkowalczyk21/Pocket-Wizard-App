//
//  TamperSensitivitySlider.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/11/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class TamperSensitivitySlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isContinuous = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isContinuous = true
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                thumbTintColor = .systemYellow
            } else {
                thumbTintColor = .lightGray
            }
        }
    }
}
