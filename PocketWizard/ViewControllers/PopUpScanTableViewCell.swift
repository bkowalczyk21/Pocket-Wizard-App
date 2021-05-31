//
//  PopUpScanTableViewCell.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 5/22/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class PopUpScanTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        deviceLabel.font = UIFont(name: "Arial-BoldMT", size: 20)
        cellView.layer.cornerRadius = 20
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cellView.layer.shadowRadius = 3
        cellView.layer.shadowOpacity = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setConnectingAnimation(_ connecting: Bool) {
        if connecting {
            connectingIndicator.isHidden = false
            connectingIndicator.startAnimating()
        } else {
            connectingIndicator.isHidden = true
            connectingIndicator.stopAnimating()
        }
    }
}
