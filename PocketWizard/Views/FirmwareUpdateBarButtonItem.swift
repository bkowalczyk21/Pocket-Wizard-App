//
//  FirmwareUpdateBarButtonItem.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/13/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class FirmwareUpdateBarButtonItem: UIBarButtonItem {
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                image = UIImage(named: "Icon open-arrow-thick-top")
            } else {
                image = UIImage()
            }
        }
    }
}
