//
//  AdvancedViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/8/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class AdvancedViewController: UIViewController {
    
    // Storyboard Outlets
    @IBOutlet weak var advancedLabel: UILabel!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var pinOnOffSwitch: UISwitch!
    @IBOutlet weak var firmwareVersionLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var firmwareUpdateLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    // Models
    var advanced: Advanced!
    //var firmwareUpdate: FirmwareUpdate?
    var firmwareUpdateManager: FirmwareUpdateManager!
    
    // TODO: Move to model
    var firmwareString: String?
    var shouldStartUpdate: Bool?
    
    /****************View Controller Delegate Methods********************/
    
    override func viewDidLoad() {
        // Load the View
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        
        // Add PW logo to nav bar title view
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: pocketWizardLogo)
        logoContainer.addSubview(logoView)
        self.navigationItem.titleView = logoContainer
        
        // Advanced label font
        advancedLabel.font = UIFont(name: "Arial-BoldMT", size: 28)
        
        // Get device info
        //let modelNumber = advanced.getFirmwareVersion()
        let name = advanced.getName()
        
        // Underline name and pin
        let pinString = NSAttributedString(string: "7777", attributes: [NSAttributedString.Key.underlineStyle: 1,
                        NSAttributedString.Key.underlineColor: UIColor.white,
                        NSAttributedString.Key.foregroundColor: UIColor.white])
        let nameString = NSAttributedString(string: name, attributes: [NSAttributedString.Key.underlineStyle: 1,
                        NSAttributedString.Key.underlineColor: UIColor.white,
                        NSAttributedString.Key.foregroundColor: UIColor.white])
        nameButton.setAttributedTitle(nameString, for: .normal)
        pinButton.setAttributedTitle(pinString, for: .normal)
        
        // Set pin switch
       
        pinOnOffSwitch.isEnabled = false
        pinOnOffSwitch.isOpaque = true
        pinOnOffSwitch.setOn(false, animated: true)
        
        
        // Set device info
        //firmwareVersionLabel.text = firmwareVerison
        serialNumberLabel.text = "XXC3393DJD"
        
        // Update percentage UI scheme
        percentageLabel.font = UIFont(name: "Arial-BoldMT", size: 48)
        percentageLabel.isHidden = true
        percentageLabel.textColor = .white
        
        // Update label UI scheme
        firmwareUpdateLabel.textColor = .black
        firmwareUpdateLabel.isHidden = true
        
        // Update button UI Scheme
        updateButton.backgroundColor = .clear
        updateButton.layer.cornerRadius = 20
        updateButton.layer.borderWidth = 1
        updateButton.layer.borderColor = UIColor.black.cgColor
        updateButton.isHidden = true
        updateButton.isEnabled = false
        
        // Progress view UI scheme
        progressView.progressTintColor = .white
        progressView.trackTintColor = .lightGray
        progressView.isHidden = true
        
        // If an update is available enable and "unhide" update button and label
        //if firmwareUpdate != nil {
            firmwareUpdateLabel.text = "An update is available."
            firmwareUpdateLabel.isHidden = false
            updateButton.isHidden = false
            updateButton.isEnabled = true
        //}
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // If segue initiated from pressing "update" in settings alert, start update immediately
        if shouldStartUpdate ?? false {
            shouldStartUpdate = false
            startUpdate()
        }
    }
    
    
    /****************Storybard Actions***************/
    
    
    @IBAction func changePinAction(_ sender: UIButton) {
        // User pressed on their PIN, offer to them to change it
        let alert = UIAlertController(title: "Change PIN Code", message: "Choose a new PIN code for your PocketWizard", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField!) in
            textField.placeholder = "0489"
        }
        // Create action on "Save" pressed
        let saveAction = UIAlertAction(title: "Save", style: .default) { (saveAction) in
            let userName = alert.textFields![0] as UITextField
            // Set PIN code
            //self.advanced.setPinCode(pinCode: userName.text ?? "")
            if userName.text != "" {
                // If code entered, adjust UI accordingly
                //self.advanced.setPinEnable(enabled: true)
                self.pinOnOffSwitch.isEnabled = true
                self.pinOnOffSwitch.isOpaque = false
                self.pinOnOffSwitch.setOn(true, animated: true)
                let pinString = NSAttributedString(string: userName.text!, attributes: [NSAttributedString.Key.underlineStyle: 1,
                NSAttributedString.Key.underlineColor: UIColor.white,
                NSAttributedString.Key.foregroundColor: UIColor.white])
                self.pinButton.setAttributedTitle(pinString, for: .normal)
            } else {
                // Otherwise user entered nothing, disable PIN enable switch
                //self.advanced.setPinEnable(enabled: false)
                self.pinOnOffSwitch.isEnabled = false
                self.pinOnOffSwitch.isOpaque = true
                self.pinOnOffSwitch.setOn(false, animated: true)
                //let pin = self.advanced.getPinCode()
                let pinString = NSAttributedString(string: "7777", attributes: [NSAttributedString.Key.underlineStyle: 1,
                    NSAttributedString.Key.underlineColor: UIColor.white,
                    NSAttributedString.Key.foregroundColor: UIColor.white])
                self.pinButton.setAttributedTitle(pinString, for: .normal)
            }
            alert.dismiss(animated: true, completion: nil)
        }
        // Action on cancel pressed
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (cancelAction) in
            // Dismiss alert
            alert.dismiss(animated: true, completion: nil)
        }
        
        // Add save and cancel actions
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pinEnableAction(_ sender: UISwitch) {
        // User toggled PIN enabled switch, set PIN security On/Off
        if pinOnOffSwitch.isOn {
            //advanced.setPinEnable(enabled: true)
        } else {
            //advanced.setPinEnable(enabled: false)
        }
    }
    
    @IBAction func changeNameAction(_ sender: UIButton) {
        // User pressed on device name, offer them to change it
        let nameAlert = UIAlertController(title: "Change Name", message: "Choose a new name for your PocketWizard", preferredStyle: .alert)
        nameAlert.addTextField { (nameField: UITextField!) in
            nameField.placeholder = "Name"
        }
        
        // Create save action
        let saveAction = UIAlertAction(title: "Save", style: .default) { (saveAction) in
            let userName = nameAlert.textFields![0] as UITextField
            if userName.text != "" {
                // If a name was entered, set name to device and update UI
                //self.advanced.setName(name: userName.text!)
                let nameString = NSAttributedString(string: userName.text!, attributes: [NSAttributedString.Key.underlineStyle: 1,
                NSAttributedString.Key.underlineColor: UIColor.white,
                NSAttributedString.Key.foregroundColor: UIColor.white])
                self.nameButton.setAttributedTitle(nameString, for: .normal)
            }
            nameAlert.dismiss(animated: true, completion: nil)
        }
        
        // Create canacel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (cancelAction) in
            // Dismiss alert
            nameAlert.dismiss(animated: true, completion: nil)
        }
        
        // Add save and cancel actions
        nameAlert.addAction(saveAction)
        nameAlert.addAction(cancelAction)
        
        self.present(nameAlert, animated: true, completion: nil)
    }
    
    @IBAction func startUpdateAction(_ sender: UIButton) {
        // User pressed update button, call startUpdate() helper method
        startUpdate()
        
    }
    
    
    /******************Helper Methods*****************/
    
    
    func startUpdate() {
        // Set up update UI
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.updateButton.isEnabled = false
        self.updateButton.layer.borderColor = UIColor.clear.cgColor
        self.updateButton.setTitleColor(.white, for: .disabled)
        self.updateButton.setTitle("Loading Firmware...", for: .disabled)
        // Call FirmwareUpdate object to start and update
        firmwareUpdateManager.initateFirmwareUpdate(delegate: self)
    }
    
    // TODO: If firmware upgrade model is nil then make sure user can't do anything update related.

}

extension AdvancedViewController: FirmwareUpdateDelegate {
    func didInitiateUpdate() {
        updateButton.setTitle("Updating...", for: .disabled)
        firmwareUpdateLabel.text = "Please stand within five feet of your PocketWizard while update is in progress."
        percentageLabel.isHidden = false
        progressView.isHidden = false
        percentageLabel.text = "0%"
        progressView.progress = 0.0
    }
    
    func didUpdateFileLocation(percentage: Double) {
        percentageLabel.text = String(percentage) + "%"
        progressView.progress = Float(percentage)
        
    }
    
    func didCompleteUpdate() {
        self.navigationItem.setHidesBackButton(false, animated: true)
        firmwareUpdateLabel.text = "Upload completed"
        // Dummy hard code
        firmwareVersionLabel.text = "001.201"
        //advanced.setFirmwareVersion(version: "001.201")
        updateButton.setTitleColor(.clear, for: .disabled)
        percentageLabel.isHidden = true
        progressView.trackTintColor = .clear
        progressView.progressTintColor = .clear
        // Present upgrade completed alert
        let alert = UIAlertController(title: "Upload Completed", message: "Image upload finished.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            //self.performSegue(withIdentifier: "UnwindToAdvancedSettings", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func firmwareUpdateFailed(error: String) {
        let alert = UIAlertController(title: "Update Completed", message: "Firmware upgrade successful.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            //self.performSegue(withIdentifier: "UnwindToAdvancedSettings", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

