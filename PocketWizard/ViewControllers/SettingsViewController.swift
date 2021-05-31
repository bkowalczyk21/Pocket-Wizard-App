//
//  SettingsViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/15/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//

//let plusIIIBodyOn = "PW_Plus_III_Transparent-background"
//let plusIIIBodyOff = "PW_Plus_III_Transparent-background-off"
let pocketWizardLogo = "PW_Logo_Clear_White"
let disconnectIcon = "link-disconnected"
let connectIcon = "link-connected"
let shutterIcon = "shutter-icon"
let twoToneShutterIcon = "shutter-icon-twotone"
let nr1Connected = "NR1-Blue"
let nr1Disconnected = "NR1-White"

import UIKit
import CoreBluetooth
import AudioToolbox

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Storyboard Outlets
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var channelPickerView: UIPickerView!
    @IBOutlet weak var zoneTitle: UILabel!
    @IBOutlet weak var zoneAButton: UIButton!
    @IBOutlet weak var zoneBButton: UIButton!
    @IBOutlet weak var zoneCButton: UIButton!
    @IBOutlet weak var zoneDButton: UIButton!
    @IBOutlet weak var zoneEButton: UIButton!
    @IBOutlet weak var zoneFButton: UIButton!
    @IBOutlet weak var zoneGButton: UIButton!
    @IBOutlet weak var zoneHButton: UIButton!
    @IBOutlet weak var channelView: UIView!
    @IBOutlet weak var zoneView: UIView!
    @IBOutlet weak var tamperView: UIView!
    @IBOutlet weak var tamperEnableButton: UIButton!
    @IBOutlet weak var tamperSensitivitySlider: UISlider!
    @IBOutlet weak var tamperTitle: UILabel!
    @IBOutlet weak var channelDownButton: UIButton!
    @IBOutlet weak var channelUpButton: UIButton!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var firmwareUpdateButton: UIBarButtonItem!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var connectLabel: UILabel!
    
    // Settings Presenter
    var settings: Settings!
    
    // TODO: Move to settings View Model if sensible
    var doingAlert: Bool = false
    var latestFirmware: String?
    var didFirmwareAlert: Bool = false
    var firmwareString: String?
    var userInitaitedUpdate: Bool = false
    var connected: Bool = false
    var selectedZoneButton: UIButton!
    
    let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    /*******************View Controller Delegate Methods**********************/
    
    override func viewDidLoad() {
        //Load View
        super.viewDidLoad()
        
        // Set navigation bar to blue and tint color to green
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Add PW logo to nav bar title view
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: pocketWizardLogo)
        logoContainer.addSubview(logoView)
        self.navigationItem.titleView = logoContainer
        
        channelPickerView.delegate = self
        channelPickerView.dataSource = self
        //let y = channelPickerView.frame.origin.y
        setUpBaseUI()
        updateChannel()
        updateTamperSettings()
        disableUI()
        
        
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove observers
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: triggerCharacteristicDidWriteNotification), object: nil)
        removeObservers()
        BluetoothPeripherals.blePeripherals.savePeripherals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Add observers for trigers, tampers and connection changes
        addObservers()
        
        
        deviceNameLabel.text = settings.getName()
        settings.channelFirstRead = true
        settings.tamperFirstRead = true
        // Gray and disable buttons if disconnected
        let state = settings.getState()
        switch state {
        case .connected:
            // DO this section *******************
            updateChannel()
            updateTamperSettings()
            enableChannelUI()
            enableTamperUI()
            deviceImage.image = UIImage(named: nr1Connected)
            deviceNameLabel.text = settings.getName()
            deviceNameLabel.textColor = .darkGray
            testButton.isEnabled = true
            if settings.firmwareUpdateIsAvailable() {
                firmwareUpdateButton.isEnabled = true
                firmwareUpdateButton.image = UIImage(named: "Icon open-arrow-thick-top")
            } else {
                firmwareUpdateButton.isEnabled = false
                firmwareUpdateButton.image = UIImage()
            }
        case .disconnected:
            settings.connect()
        default:
            print("This should never happen")
        }

        print("Appearing")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.settings.getState() == .connecting && !self.connected {
                // If connection has not yet happened, cancel and present alert
                self.settings.disconnect()
                print(self.settings.getState())
                let alert = UIAlertController(title: "Connection Failed", message: "Failed to connect to device. Please ensure device is turned on, in range and advertising.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default) { (okayAction) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        if segue.identifier == "FirmwareUpdateSegue" {
            // Is segueing to advanced settings, pass along firware info.
                if let controller = segue.destination as? FirmwareUpdatesViewController {
                    controller.firmwareUpdatesManager = FirmwareUpdateManager(index: settings.getIndex())
            }
        }
         */
    }
    
    
    /*****************Storyboard Actions********************/

    @IBAction func connectAction(_ sender: UIButton) {
        let state = settings.getState()
        if state == .connected {
            settings.disconnect()
        } else if state == .disconnected {
            settings.connect()
            connectLabel.text = "Connecting..."
        } else {
            return
        }
    }
    
    
    @IBAction func changeModeAction(_ sender: UIButton) {
        settings.toggleMode()
    }
    
    @IBAction func channelUpAction(_ sender: UIButton) {
        settings.channelUp()
    }
    
    @IBAction func channelDownAction(_ sender: UIButton) {
        settings.channelDown()
    }
    
    
    @IBAction func zoneAAction(_ sender: UIButton) {
        settings.setZone(zone: zoneA)
    }
    
    @IBAction func zoneBAction(_ sender: UIButton) {
        settings.setZone(zone: zoneB)
    }
    
    @IBAction func zoneCAction(_ sender: UIButton) {
        settings.setZone(zone: zoneC)
    }
    
    @IBAction func zoneDAction(_ sender: UIButton) {
        settings.setZone(zone: zoneD)
    }
    
    @IBAction func zoneEAction(_ sender: UIButton) {
        settings.setZone(zone: zoneE)
    }
    
    @IBAction func zoneFAction(_ sender: UIButton) {
        settings.setZone(zone: zoneF)
    }
    
    @IBAction func zoneGAction(_ sender: UIButton) {
        settings.setZone(zone: zoneG)
    }
    
    @IBAction func zoneHAction(_ sender: UIButton) {
        settings.setZone(zone: zoneH)
    }
   
    
    
    @IBAction func testAction(_ sender: UIButton) {
        // User pressed test button, if connected, call  trigger function
        testButton.isSelected = true
        settings.testTrigger()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.testButton.isSelected = false
        }
    }
    
    @IBAction func setTamperEnabled(_ sender: UIButton) {
        settings.toggleTamperEnabled()
    }
    
    
    @IBAction func setTamperSensitivityAction(_ sender: UISlider) {
        let sensitivity = tamperSensitivitySlider.value * 100
        if sensitivity < 33 {
            tamperSensitivitySlider.setValue(0, animated: true)
            settings.setTamperSensitivity(sensitivity: 0)
        } else if sensitivity >= 33 && sensitivity < 67 {
            tamperSensitivitySlider.setValue(0.5, animated: true)
            settings.setTamperSensitivity(sensitivity: 1)
        } else if sensitivity >= 67 {
            tamperSensitivitySlider.setValue(1, animated: true)
            settings.setTamperSensitivity(sensitivity: 2)
        }
        print(sensitivity)
        print(Int(sensitivity))
    }
    
    
    
    /**************Objectice-C Style Selector Methdos************/
    
    
    @objc func peripheralConnectionDidUpdate() {
        // Observer recieved a connection update notification, check new current state
        let state = settings.getState()
        switch state {
        case .connected:
            // Device just connected
            connected = true
            deviceImage.image = UIImage(named: nr1Connected)
            if settings.firmwareUpdateIsAvailable() {
                firmwareUpdateButton.isEnabled = true
                firmwareUpdateButton.image = UIImage(named: "Icon open-arrow-thick-top")
            } else {
                firmwareUpdateButton.isEnabled = false
                firmwareUpdateButton.image = UIImage()
            }
            // Optionally present firmware update icon if available
        case .disconnected:
            // Device desconnecting, disable everything
            settings.channelFirstRead = true
            settings.tamperFirstRead = true
            heavyGenerator.impactOccurred()
            connectLabel.text = "Connect"
            connectButton.setImage(UIImage(named: connectIcon), for: .normal)
            disableUI()
        default:
            print("This should never happen")
        }
    }
    
    @objc func testCharacteristicDidWrite() {
        // Trigger did write succesfully, present a "shot taken" alert
        //didActionAlert(title: "Shot Taken!", message: "Your remote device triggered successfully")
        //testButton.isSelected = false
        mediumGenerator.impactOccurred()
    }
    
    @objc func deviceDidMove(_ notification: Notification) {
        mediumGenerator.impactOccurred()
        // Device moved, present alert
        if let data = notification.userInfo as? [CBPeripheral: Tamper] {
            for (peripheral, tamper) in data {
                let name = settings.getName()
                let distance = tamper.getFormattedDistance()
                // Don't present if already presenting
                if !doingAlert {
                    doingAlert = true
                    didActionAlert(title: "Tamper Alert!", message: "Motion detected at " + name + ". Please ensure camera has not been tampered with. Movement amount: " + distance)
                }
            }
        }
    }
    
    @objc func didReadName() {
        deviceNameLabel.text = settings.getName()
        deviceNameLabel.textColor = .darkGray
    }
    
    @objc func didReadChannel() {
        updateChannel()
        if settings.channelFirstRead {
            enableChannelUI()
            settings.channelFirstRead = false
        } else {
            mediumGenerator.impactOccurred()
        }
        
    }
    
    @objc func didReadTamperSettings() {
        mediumGenerator.impactOccurred()
        updateTamperSettings()
        if settings.tamperFirstRead {
            enableTamperUI()
            connectLabel.text = "Disconnect"
            connectButton.setImage(UIImage(named: disconnectIcon), for: .normal)
            settings.tamperFirstRead = false
        }
    }
    
    @objc func didWriteName() {
        deviceNameLabel.text = settings.getName()
    }
    
    @objc func testCharacteristicDiscovered() {
        testButton.isEnabled = true
    }
    
    
    /*****************Helper Methods*****************/
    
    func addObservers() {
         NotificationCenter.default.addObserver(self, selector: #selector(peripheralConnectionDidUpdate),
                                                name: NSNotification.Name(rawValue: peripheralDidConnectNotification), object: nil)
         
         NotificationCenter.default.addObserver(self, selector: #selector(peripheralConnectionDidUpdate),
                                                name: NSNotification.Name(rawValue: peripheralDidDisconnectNotification), object: nil)
         // ** Consider this observer - what should lifetime be?
         NotificationCenter.default.addObserver(self, selector: #selector(deviceDidMove(_:)),
                                                name: NSNotification.Name(rawValue: deviceDidMoveNotification), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(didReadChannel),
         name: NSNotification.Name(rawValue: didReadChannelCharacteristicNotification), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(didReadTamperSettings),
         name: NSNotification.Name(rawValue: didReadTamperSettingsCharacteristicNotification), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(didReadName),
         name: NSNotification.Name(rawValue: didReadManufacturerNameCharacteristicNotification), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(didWriteName),
         name: NSNotification.Name(rawValue: didWriteNameCharacteristicNotification), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(testCharacteristicDiscovered),
         name: NSNotification.Name(rawValue: testCharacteristicDiscoveredNotification), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(testCharacteristicDidWrite), name: NSNotification.Name(rawValue: testCharacteristicDidWriteNotification), object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(peripheralDidConnectNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(peripheralDidDisconnectNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(deviceDidMoveNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(didReadChannelCharacteristicNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(didReadTamperSettingsCharacteristicNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(didReadManufacturerNameCharacteristicNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(didWriteNameCharacteristicNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(testCharacteristicDiscoveredNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(testCharacteristicDidWriteNotification), object: nil)
    }
    
    //Present an action alert
    func didActionAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.doingAlert = false
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateChannel() {
        channelPickerView.reloadComponent(0)
        channelPickerView.selectRow(settings.getChannel() - 1, inComponent: 0, animated: true)
        
        let zonesString = settings.getZones()
        if zonesString.contains("A") {
            zoneAButton.backgroundColor = .systemGreen
            zoneAButton.setTitleColor(.white, for: .normal)
        } else {
            zoneAButton.backgroundColor = .darkGray
            zoneAButton.setTitleColor(.systemGreen, for: .normal)
        }
        if zonesString.contains("B") {
            zoneBButton.backgroundColor = .systemGreen
            zoneBButton.setTitleColor(.white, for: .normal)
        } else {
            zoneBButton.backgroundColor = .darkGray
            zoneBButton.setTitleColor(.systemGreen, for: .normal)
        }
        if zonesString.contains("C") {
            zoneCButton.backgroundColor = .systemGreen
            zoneCButton.setTitleColor(.white, for: .normal)
        } else {
            zoneCButton.backgroundColor = .darkGray
            zoneCButton.setTitleColor(.systemGreen, for: .normal)
        }
        if zonesString.contains("D") {
            zoneDButton.backgroundColor = .systemGreen
            zoneDButton.setTitleColor(.white, for: .normal)
        } else {
            zoneDButton.backgroundColor = .darkGray
            zoneDButton.setTitleColor(.systemGreen, for: .normal)
        }
        
        let mode = settings.getMode()
        if mode == 0x00 {
            modeButton.setImage(UIImage(named: "Icon feather-camera"), for: .normal)
            zoneEButton.backgroundColor = .lightGray
            zoneFButton.backgroundColor = .lightGray
            zoneGButton.backgroundColor = .lightGray
            zoneHButton.backgroundColor = .lightGray
            zoneEButton.isEnabled = false
            zoneFButton.isEnabled = false
            zoneGButton.isEnabled = false
            zoneHButton.isEnabled = false
            
        } else if mode == 0x01 {
            modeButton.setImage(UIImage(named: "Icon feather-camera-1"), for: .normal)
            if zonesString.contains("E") {
                zoneEButton.backgroundColor = .systemGreen
                zoneEButton.setTitleColor(.white, for: .normal)
            } else {
                zoneEButton.backgroundColor = .darkGray
                zoneEButton.setTitleColor(.systemGreen, for: .normal)
            }
            if zonesString.contains("F") {
                zoneFButton.backgroundColor = .systemGreen
                zoneFButton.setTitleColor(.white, for: .normal)
            } else {
                zoneFButton.backgroundColor = .darkGray
                zoneFButton.setTitleColor(.systemGreen, for: .normal)
            }
            if zonesString.contains("G") {
                zoneGButton.backgroundColor = .systemGreen
                zoneGButton.setTitleColor(.white, for: .normal)
            } else {
                zoneGButton.backgroundColor = .darkGray
                zoneGButton.setTitleColor(.systemGreen, for: .normal)
            }
            if zonesString.contains("H") {
                zoneHButton.backgroundColor = .systemGreen
                zoneHButton.setTitleColor(.white, for: .normal)
            } else {
                zoneHButton.backgroundColor = .darkGray
                zoneHButton.setTitleColor(.systemGreen, for: .normal)
            }
            
            zoneEButton.isEnabled = true
            zoneFButton.isEnabled = true
            zoneGButton.isEnabled = true
            zoneHButton.isEnabled = true
        }
    }
    
    func updateTamperSettings() {
        let enabled = settings.getTamperState()
        if enabled == 0x00 {
            tamperEnableButton.setImage(UIImage(named: "Icon awesome-unlock"), for: .normal)
        } else if enabled == 0x01 {
            tamperEnableButton.setImage(UIImage(named: "Icon awesome-lock"), for: .normal)
        }
        let sensitivity = settings.getTamperSensitivity()
        if sensitivity == 0 {
            tamperSensitivitySlider.value = 0
        } else if sensitivity == 1 {
            tamperSensitivitySlider.value = 0.5
        } else if sensitivity == 2 {
            tamperSensitivitySlider.value = 1
        }
    }
    
    func enableTamperUI() {
        tamperView.layer.shadowOpacity = 0.3
        tamperTitle.textColor = .systemYellow
        tamperEnableButton.isEnabled = true
        tamperSensitivitySlider.thumbTintColor = .systemYellow
        tamperSensitivitySlider.isEnabled = true
    }
    
    func enableChannelUI() {
        channelView.layer.shadowOpacity = 0.3
        zoneView.layer.shadowOpacity = 0.3
        channelTitle.textColor = .systemBlue
        zoneTitle.textColor = .systemGreen
        
        modeButton.isEnabled = true
        
        channelPickerView.selectRow(settings.getChannel() - 1, inComponent: 0, animated: true)
        channelPickerView.isUserInteractionEnabled = true
        channelPickerView.alpha = 1.0
        channelUpButton.isEnabled = true
        channelDownButton.isEnabled = true
        
        zoneAButton.isEnabled = true
        zoneBButton.isEnabled = true
        zoneCButton.isEnabled = true
        zoneDButton.isEnabled = true
    }
    
    func disableUI() {
        deviceNameLabel.textColor = .lightGray
        channelPickerView.isUserInteractionEnabled = false
        channelPickerView.alpha = 0.7
        channelUpButton.isEnabled = false
        channelDownButton.isEnabled = false
        
        channelView.layer.shadowOpacity = 0
        zoneView.layer.shadowOpacity = 0
        tamperView.layer.shadowOpacity = 0
        
        channelTitle.textColor = UIColor.systemBlue.withAlphaComponent(0.8)
        zoneTitle.textColor = UIColor.systemGreen.withAlphaComponent(0.8)
        tamperTitle.textColor = UIColor.systemYellow.withAlphaComponent(0.8)
               
        modeButton.setImage(UIImage(named: "Icon feather-camera-80%"), for: .disabled)
        modeButton.isEnabled = false
        
        zoneAButton.backgroundColor = zoneAButton.backgroundColor?.withAlphaComponent(0.7)
        zoneBButton.backgroundColor = zoneBButton.backgroundColor?.withAlphaComponent(0.7)
        zoneCButton.backgroundColor = zoneCButton.backgroundColor?.withAlphaComponent(0.7)
        zoneDButton.backgroundColor = zoneDButton.backgroundColor?.withAlphaComponent(0.7)
        zoneEButton.backgroundColor = zoneEButton.backgroundColor?.withAlphaComponent(0.7)
        zoneFButton.backgroundColor = zoneFButton.backgroundColor?.withAlphaComponent(0.7)
        zoneGButton.backgroundColor = zoneGButton.backgroundColor?.withAlphaComponent(0.7)
        zoneHButton.backgroundColor = zoneHButton.backgroundColor?.withAlphaComponent(0.7)
        
        zoneAButton.isEnabled = false
        zoneBButton.isEnabled = false
        zoneCButton.isEnabled = false
        zoneDButton.isEnabled = false
        zoneEButton.isEnabled = false
        zoneFButton.isEnabled = false
        zoneGButton.isEnabled = false
        zoneHButton.isEnabled = false
        
        tamperEnableButton.setImage(UIImage(named: "Icon awesome-lock80%"), for: .disabled)
        tamperEnableButton.isEnabled = false
        
        tamperSensitivitySlider.thumbTintColor = .lightGray
        tamperSensitivitySlider.isEnabled = false
        
        testButton.isEnabled = false
        
        firmwareUpdateButton.isEnabled = false
        firmwareUpdateButton.image = UIImage()
        
        deviceImage.image = UIImage(named: nr1Disconnected)
    }
    
    
    func setUpBaseUI() {
        channelPickerView.transform = CGAffineTransform(rotationAngle: 270 * (.pi/180))
        //channelPickerView.frame = CGRect(x: -50, y: y, width: 124, height: 100)
        
        channelView.layer.cornerRadius = 20
        zoneView.layer.cornerRadius = 20
        tamperView.layer.cornerRadius = 20
        
        channelView.layer.shadowColor = UIColor.black.cgColor
        zoneView.layer.shadowColor = UIColor.black.cgColor
        tamperView.layer.shadowColor = UIColor.black.cgColor
        
        channelView.layer.shadowOffset = CGSize(width: 0, height: 3)
        zoneView.layer.shadowOffset = CGSize(width: 0, height: 3)
        tamperView.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        channelView.layer.shadowRadius = 3
        zoneView.layer.shadowRadius = 3
        tamperView.layer.shadowRadius = 3
        
        // Firmware update
        firmwareUpdateButton.isEnabled = false
        firmwareUpdateButton.image = UIImage()
        
        // Settings Label
        deviceNameLabel.text = settings.getName()
        deviceNameLabel.font = UIFont(name: "Arial-BoldMT", size: 20)
        channelTitle.font = UIFont(name: "Arial-BoldMT", size: 24)
        zoneTitle.font = UIFont(name: "Arial-BoldMT", size: 24)
        tamperTitle.font = UIFont(name: "Arial-BoldMT", size: 24)
        
        channelPickerView.selectRow(0, inComponent: 0, animated: true)
        
        zoneAButton.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        zoneBButton.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        zoneCButton.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        zoneDButton.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        zoneEButton.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        zoneFButton.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        zoneGButton.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        zoneHButton.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        
        zoneAButton.layer.cornerRadius = 25
        zoneBButton.layer.cornerRadius = 25
        zoneCButton.layer.cornerRadius = 25
        zoneDButton.layer.cornerRadius = 25
        zoneEButton.layer.cornerRadius = 25
        zoneFButton.layer.cornerRadius = 25
        zoneGButton.layer.cornerRadius = 25
        zoneHButton.layer.cornerRadius = 25
        /*
        zoneAButton.layer.shadowColor = UIColor.black.cgColor
        zoneBButton.layer.shadowColor = UIColor.black.cgColor
        zoneCButton.layer.shadowColor = UIColor.black.cgColor
        zoneDButton.layer.shadowColor = UIColor.black.cgColor
        zoneEButton.layer.shadowColor = UIColor.black.cgColor
        zoneFButton.layer.shadowColor = UIColor.black.cgColor
        zoneGButton.layer.shadowColor = UIColor.black.cgColor
        zoneHButton.layer.shadowColor = UIColor.black.cgColor
        
        zoneAButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        zoneBButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        zoneCButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        zoneDButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        zoneEButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        zoneFButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        zoneGButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        zoneHButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        zoneAButton.layer.shadowRadius = 3
        zoneBButton.layer.shadowRadius = 3
        zoneCButton.layer.shadowRadius = 3
        zoneDButton.layer.shadowRadius = 3
        zoneEButton.layer.shadowRadius = 3
        zoneFButton.layer.shadowRadius = 3
        zoneGButton.layer.shadowRadius = 3
        zoneHButton.layer.shadowRadius = 3
        
        zoneAButton.layer.shadowOpacity = 0.5
        zoneBButton.layer.shadowOpacity = 0.5
        zoneCButton.layer.shadowOpacity = 0.5
        zoneDButton.layer.shadowOpacity = 0.5
        zoneEButton.layer.shadowOpacity = 0.5
        zoneFButton.layer.shadowOpacity = 0.5
        zoneGButton.layer.shadowOpacity = 0.5
        zoneHButton.layer.shadowOpacity = 0.5
        */
        zoneAButton.setTitleColor(.lightText, for: .disabled)
        zoneBButton.setTitleColor(.lightText, for: .disabled)
        zoneCButton.setTitleColor(.lightText, for: .disabled)
        zoneDButton.setTitleColor(.lightText, for: .disabled)
        zoneEButton.setTitleColor(.lightText, for: .disabled)
        zoneFButton.setTitleColor(.lightText, for: .disabled)
        zoneGButton.setTitleColor(.lightText, for: .disabled)
        zoneHButton.setTitleColor(.lightText, for: .disabled)
        
        // Only record sensitivty once user stops moving slider
        tamperSensitivitySlider.isContinuous = false
        
        testButton.setImage(UIImage(named: twoToneShutterIcon), for: .selected)
        testButton.setImage(UIImage(named: shutterIcon), for: .normal)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if settings.getMode() == 0x00 {
            return settings.flashModeChannelPickerData.count
        } else {
            return settings.cameraModeChannelPickerData.count
        }
    }
    /*
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if settings.getMode() == 0x00 {
            return settings.flashModeChannelPickerData[row]
        } else {
            return settings.camerModeChannelPickerData[row]
        }
    }
   */
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        settings.setChannel(channelPicked: row + 1)
    }
 
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "ArialMT", size: 32)
        titleLabel.textAlignment = NSTextAlignment.center
        if settings.getMode() == 0x00 {
            titleLabel.text = settings.flashModeChannelPickerData[row]
        } else {
            titleLabel.text = settings.cameraModeChannelPickerData[row]
        }
        titleLabel.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))
        return titleLabel
    }
    
}


