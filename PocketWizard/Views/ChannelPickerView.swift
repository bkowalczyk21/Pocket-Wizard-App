//
//  ChannelPickerView.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/11/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class ChannelPickerView: UIPickerView {
    override var isUserInteractionEnabled: Bool {
        didSet {
            if isUserInteractionEnabled {
                alpha = 1.0
            } else {
                alpha = 0.7
            }
        }
    }
}
