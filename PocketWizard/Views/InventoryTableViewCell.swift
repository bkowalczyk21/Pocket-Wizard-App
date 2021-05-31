//
//  InventoryTableViewCell.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/15/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//



import Foundation
import UIKit

class InventoryTableViewCell: UITableViewCell {
    
    // Storyboard Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var zonesTitleLabel: UILabel!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var zonesLabel: UILabel!
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var cameraModeIcon: UIImageView!
    @IBOutlet weak var tamperStateIcon: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Title fonts
        nameLabel.font = UIFont(name: "Arial-BoldMT", size: 20)
        channelLabel.font = UIFont(name: "Arial-BoldMT", size: 30)
        zonesLabel.font = UIFont(name: "Arial-BoldMT", size: 24)
        channelTitleLabel.font = UIFont(name: "Arial-BoldMT", size: 13)
        zonesTitleLabel.font = UIFont(name: "Arial-BoldMT", size: 13)
        
        cellView.layer.cornerRadius = 20
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cellView.layer.shadowRadius = 3
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            // Hightlight cell for .2 seconds
            self.backgroundColor = UIColor(red: 0.941, green: 1.0, blue: 1.0, alpha: 0.25)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.backgroundColor = .clear
            }
        }
        
        // Configure the view for the selected state
    }
    
    func setTamperStateIndicatorOn() {
        tamperStateIcon.image = UIImage(named: "Icon awesome-lock")
    }
    
    func setTamperStateIndicatorOff() {
        tamperStateIcon.image = UIImage(named: "Icon awesome-unlock")
    }
    
    func setModeIndicatorToCamera() {
        cameraModeIcon.image = UIImage(named: "Icon feather-camera-1")
    }
    
    func setModeIndicatorToFlash() {
        cameraModeIcon.image = UIImage(named: "Icon feather-camera")
    }
    
    func setCellAsDisconnected() {
        nameLabel.textColor = .lightGray
        channelTitleLabel.textColor = .lightGray
        zonesTitleLabel.textColor = .lightGray
        channelLabel.textColor = UIColor.systemBlue.withAlphaComponent(0.8)
        zonesLabel.textColor = UIColor.systemGreen.withAlphaComponent(0.8)
        cellView.alpha = 0.8
        deviceImage.image = UIImage(named: "NR1-White")
        cellView.layer.shadowOpacity = 0
    }
    
    func setCellAsConnected() {
        nameLabel.textColor = .darkGray
        channelTitleLabel.textColor = .darkGray
        zonesTitleLabel.textColor = .darkGray
        channelLabel.textColor = .systemBlue
        zonesLabel.textColor = .systemGreen
        cellView.alpha = 1.0
        deviceImage.image = UIImage(named: "NR1-Blue")
        cellView.layer.shadowOpacity = 0.3
    }
}
