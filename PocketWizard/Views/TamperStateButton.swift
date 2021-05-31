//
//  TamperStateButton.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/11/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class TamperStateButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: "Icon awesome-unlock"), for: .normal)
        setImage(UIImage(named: "Icon awesome-lock"), for: .selected)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setImage(UIImage(named: "Icon awesome-unlock"), for: .normal)
        setImage(UIImage(named: "Icon awesome-lock"), for: .selected)
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                imageView?.alpha = 1.0
            } else {
                imageView?.alpha = 0.7
            }
        }
    }
}
