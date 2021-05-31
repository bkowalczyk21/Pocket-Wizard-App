//
//  PocketWizardImageView.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/13/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class PocketWizardImageView: UIImageView {
    func setConnected(_ connected: Bool) {
        if connected {
            image = UIImage(named: "NR1-Blue")
        } else {
            image = UIImage(named: "NR1-White")
        }
    }
}
