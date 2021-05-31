//
//  InstructionsViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/26/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {

    // Storyboard Outlets
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    
    
    override func viewDidLoad() {
        // Load the View
        super.viewDidLoad()

        // Set nav bar clear, tint color white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Add PW logo to nav bar title view
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: pocketWizardLogo)
        logoContainer.addSubview(logoView)
        self.navigationItem.titleView = logoContainer
        
        // Instructions label font and text, **TODO: Edit instructions**
        instructionsLabel.font = UIFont(name: "Arial-BoldMT", size: 22)
        informationLabel.text = "Step 1. \nTurn on your NR1 using the black button located to the side. Your device should start blinking quickly to indicate it is powering on.\n\nStep 2.\nYour NR1 should then begin to flash steadily every second indicating it is advertising over Bluetooth. Click 'Add Device' in the 'Home' tab. the device should appear in the table. Select your device and optionally give it a name and PIN. Either can be added later.\n\nStep 3.\nYour PocketWizard should now appear in your Inventory. Select it again to bring up the 'Settings' page. \n\nStep 4.\nIn 'Settings' click 'Connect,' the button will change to 'Disconnect' and your NR1 will flash a solid green for 5 seconds indicating a succesful connection.\n\nStep 5. \nConfigure the desired channel and tamper alert settings. If you are planning on receiving tamper alerts on your iOS device, stay connected when returning to your invenontory. Otherwise, disconnect and return to your inventory using the '<' button.\n\nStep 6. \nRepeat steps 1-5 for each PocketWizard. (Steps 1 & 2 are no longer necerasry once the device has been added to your inventory once.) \n\nStep 7. \nFrom your inventory, you can click 'Edit' in the top left to change the name of or remove PocketWizards in your inventory. Additionally, you can edit and enable/disable your devices bin code in 'Advanced.' When firmware updates are available they will also pop up here.\n"
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
