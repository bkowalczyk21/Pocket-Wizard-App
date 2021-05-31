//
//  ShotCounterTableViewCell.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/5/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class ShotCounterTableViewCell: UITableViewCell {
    
    
    // Storyboard Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shotsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        shotsLabel.font = UIFont(name: "Arial-BoldMT", size: 24)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {}
        // Configure the view for the selected state
    }
}
