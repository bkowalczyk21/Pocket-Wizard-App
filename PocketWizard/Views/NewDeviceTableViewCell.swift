//
//  NewDeviceTableViewCell.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/12/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class NewDeviceTableViewCell: UITableViewCell {
    
    // Storyboard Outlets
    @IBOutlet weak var peripheralLabel: UILabel!
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            // Highlight cell for .2 seconds
            self.backgroundColor = UIColor(red: 0.941, green: 1.0, blue: 1.0, alpha: 0.25)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.backgroundColor = .clear
            }
        }
        
        // Configure the view for the selected state
    }
    
}

