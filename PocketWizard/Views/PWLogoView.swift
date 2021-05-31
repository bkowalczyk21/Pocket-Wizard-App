//
//  PWLogoView.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/4/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class PWLogoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fillWithLogo()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fillWithLogo()
    }
    
    private func fillWithLogo() {
        let logoView = UIImageView(frame: frame)
        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: "PW_Logo_Clear_White")
        self.addSubview(logoView)
    }
}
