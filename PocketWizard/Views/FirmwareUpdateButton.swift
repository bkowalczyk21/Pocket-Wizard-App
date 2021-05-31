//
//  FirmwareUpdateButton.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 11/11/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class FirmwareUpdateButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGreen
        layer.cornerRadius = 20
        setTitleColor(.white, for: .normal)
        setTitleColor(.clear, for: .disabled)
        setAttributedTitle(NSAttributedString(string: "Update", attributes: [.font : UIFont(name: "Arial-BoldMT", size: 20), .foregroundColor : UIColor.white]), for: .normal)
        setAttributedTitle(NSAttributedString(string: "Update", attributes: [.font : UIFont(name: "Arial-BoldMT", size: 20), .foregroundColor : UIColor.clear]), for: .disabled)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .systemGreen
        layer.cornerRadius = 20
        setTitleColor(.white, for: .normal)
        setTitleColor(.clear, for: .disabled)
        setAttributedTitle(NSAttributedString(string: "Update", attributes: [.font : UIFont(name: "Arial-BoldMT", size: 20), .foregroundColor : UIColor.white]), for: .normal)
        setAttributedTitle(NSAttributedString(string: "Update", attributes: [.font : UIFont(name: "Arial-BoldMT", size: 20), .foregroundColor : UIColor.clear]), for: .disabled)
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = .systemGreen
            } else {
                backgroundColor = .clear
            }
        }
    }
}
