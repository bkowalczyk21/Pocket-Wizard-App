//
//  ModeSettingButton.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/11/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class ModeSettingButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
    
    var isCameraMode: Bool = true {
        didSet {
            if isCameraMode {
                setImage(UIImage(named: "Icon feather-camera-1"), for: .normal)
            } else {
                setImage(UIImage(named: "Icon feather-camera"), for: .normal)
            }
        }
    }
    
}
