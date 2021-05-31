//
//  AdvancedSettingsTableViewCell.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/18/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class AdvancedSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pinCodeLabel: UILabel!
    @IBOutlet weak var pinSettingsLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var firmwareVersionLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var pinOnButton: UIButton!
    @IBOutlet weak var pinOffButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateButton.layer.cornerRadius = 20
        updateButton.layer.borderWidth = 1
        updateButton.layer.borderColor = UIColor.white.cgColor
        //updateButton.isHidden = true
        
        let editString = NSAttributedString(string: "Edit", attributes: [NSAttributedString.Key.underlineStyle: 1,
            NSAttributedString.Key.underlineColor: UIColor.white,
            NSAttributedString.Key.foregroundColor: UIColor.white])
        
        editButton.setAttributedTitle(editString, for: .normal)
        
        nameLabel.font = UIFont(name: "Arial-BoldMT", size: 19)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
        }
        
        // Configure the view for the selected state
    }
    
}
