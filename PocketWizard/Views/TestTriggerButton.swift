//
//  TestTriggerButton.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/13/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class TestTriggerButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: "shutter-icon-twotone"), for: .normal)
        setImage(UIImage(named: "shutter-icon"), for: .selected)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setImage(UIImage(named: "shutter-icon-twotone"), for: .normal)
        setImage(UIImage(named: "shutter-icon"), for: .selected)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isSelected = false
                }
            }
        }
    }
}
