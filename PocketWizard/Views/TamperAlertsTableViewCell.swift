//
//  TamperAlertsTableViewCell.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/7/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class TamperAlertsTableViewCell: UITableViewCell {

    // Storyboard outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
        }
        // Configure the view for the selected state
    }
}
