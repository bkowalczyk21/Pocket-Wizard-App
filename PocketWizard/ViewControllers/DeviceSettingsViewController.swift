//
//  DeviceSettingsViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/11/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//


import UIKit
import CoreBluetooth

class DeviceSettingsViewController: UIViewController {

    @IBOutlet weak var deviceImageView: PocketWizardImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var channelViewTitle: SettingTitleLabel!
    @IBOutlet weak var zoneViewTitle: SettingTitleLabel!
    @IBOutlet weak var tamperViewTitle: SettingTitleLabel!
    @IBOutlet weak var channelView: RoundedShadowView!
    @IBOutlet weak var zoneView: RoundedShadowView!
    @IBOutlet weak var tamperView: RoundedShadowView!
    @IBOutlet weak var modeButton: ModeSettingButton!
    @IBOutlet weak var channelUpButton: UIButton!
    @IBOutlet weak var channelDownButton: UIButton!
    @IBOutlet weak var channelSettingPickerView: ChannelPickerView!
    @IBOutlet weak var zoneAButton: ZoneButton!
    @IBOutlet weak var zoneBButton: ZoneButton!
    @IBOutlet weak var zoneCButton: ZoneButton!
    @IBOutlet weak var zoneDButton: ZoneButton!
    @IBOutlet weak var zoneEButton: ZoneButton!
    @IBOutlet weak var zoneFButton: ZoneButton!
    @IBOutlet weak var zoneGButton: ZoneButton!
    @IBOutlet weak var zoneHButton: ZoneButton!
    @IBOutlet weak var tamperStateButton: TamperStateButton!
    @IBOutlet weak var tamperSensitivitySlider: TamperSensitivitySlider!
    @IBOutlet weak var testTriggerButton: TestTriggerButton!
    @IBOutlet weak var connectButton: ConnectButton!
    @IBOutlet weak var firmwareUpdateButton: FirmwareUpdateBarButtonItem!
    
    var selectedNR1: CBPeripheral!
    var firmwareUpdateAvailable: Bool = false
    var channelFirstRead: Bool = true
    var tamperFirstRead: Bool = true
    
    
    let zoneBytes: [String: Int] = ["": 0x00, "A": 0x01, "B": 0x02, "C": 0x04, "D": 0x08,
                                   "E": 0x10, "F": 0x20, "G": 0x40, "H": 0x80]
    
    let flashModeChannelPickerData: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32"]
    
    let cameraModeChannelPickerData: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.titleView = PWLogoView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        channelSettingPickerView.delegate = self
        channelSettingPickerView.dataSource = self
        setUpUI()
        if selectedNR1.state != .connected {
            disableUI()
            BluetoothManager.instance.connect(toNR1: selectedNR1)
            connectButton.connectionState = .connecting
        } else {
            enableChannelUI()
            //enableTamperUI()
            if let selectedNR1Data = CoreDataManager.instance.getNR1WithUUID(uuid: selectedNR1.identifier, context: CoreDataManager.instance.persistentContainer.viewContext) {
                setChannelZoneModeSettings(selectedNR1Data: selectedNR1Data)
                setTamperSettings(selectedNR1Data: selectedNR1Data)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        BluetoothManager.instance.setSettingsDelegate(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.selectedNR1.state == .connecting {
                BluetoothManager.instance.cancelConnection(toNR1: self.selectedNR1)
                let alert = UIAlertController(title: "Connection Request Timed Out", message: "Failed to connect to device. Please ensure device is turned on, in range and advertising.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default) { (okayAction) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        BluetoothManager.instance.removeSettingsDelegate()
    }
    
    @IBAction func connectButtonAction(_ sender: UIButton) {
        switch selectedNR1.state {
        case .connected:
            BluetoothManager.instance.cancelConnection(toNR1: selectedNR1)
        case .disconnected:
            BluetoothManager.instance.connect(toNR1: selectedNR1)
            connectButton.connectionState = .connecting
        default:
            return
        }
    }
    
    @IBAction func modeButtonAction(_ sender: UIButton) {
        toggleMode()
        /*if modeButton.isCameraMode {
            modeButton.isCameraMode = false
            if channelSettingPickerView.selectedRow(inComponent: 0) > 31 {
                channelSettingPickerView.selectRow(31, inComponent: 0, animated: true)
            }
        } else {
            modeButton.isCameraMode = true
        }
        setChannelZonesMode()*/
    }
    
    @IBAction func channelUpAction(_ sender: UIButton) {
        channelUp()
        /*
        var channelRow = channelSettingPickerView.selectedRow(inComponent: 0)
        channelRow += 1
        channelSettingPickerView.selectRow(channelRow, inComponent: 0, animated: true)
        setChannelZonesMode()
         */
    }
    
    @IBAction func channelDownAction(_ sender: UIButton) {
        channelDown()
        /*
        var channelRow = channelSettingPickerView.selectedRow(inComponent: 0)
        channelRow -= 1
        channelSettingPickerView.selectRow(channelRow, inComponent: 0, animated: true)
        setChannelZonesMode()
         */
    }
    
    @IBAction func zoneAButtonAction(_ sender: UIButton) {
        setZone("A")
        /*
        if zoneAButton.isSelected {
            zoneAButton.isSelected = false
        } else {
            zoneAButton.isSelected = true
        }
        setChannelZonesMode()
 */
    }
    
    @IBAction func zoneBButtonAction(_ sender: UIButton) {
        setZone("B")
        /*
        if zoneBButton.isSelected {
            zoneBButton.isSelected = false
        } else {
            zoneBButton.isSelected = true
        }
        setChannelZonesMode()
 */
    }
    
    @IBAction func zoneCButtonAction(_ sender: UIButton) {
        setZone("C")
        /*
        if zoneCButton.isSelected {
            zoneCButton.isSelected = false
        } else {
            zoneCButton.isSelected = true
        }
        setChannelZonesMode()
        */
    }
    
    @IBAction func zoneDButtonAction(_ sender: UIButton) {
        setZone("D")
        /*
        if zoneDButton.isSelected {
            zoneDButton.isSelected = false
        } else {
            zoneDButton.isSelected = true
        }
        setChannelZonesMode()
        */
    }
    
    @IBAction func zoneEButtonAction(_ sender: UIButton) {
        setZone("E")
        /*
        if zoneEButton.isSelected {
            zoneEButton.isSelected = false
        } else {
            zoneEButton.isSelected = true
        }
        setChannelZonesMode()
        */
    }
    
    @IBAction func zoneFButtonAction(_ sender: UIButton) {
        setZone("F")
        /*
        if zoneFButton.isSelected {
            zoneFButton.isSelected = false
        } else {
            zoneFButton.isSelected = true
        }
        setChannelZonesMode()
        */
    }
    
    @IBAction func zoneGButtonAction(_ sender: UIButton) {
        setZone("G")
        /*
        if zoneGButton.isSelected {
            zoneGButton.isSelected = false
        } else {
            zoneGButton.isSelected = true
        }
        setChannelZonesMode()
        */
    }
    
    @IBAction func zoneHButtonAction(_ sender: UIButton) {
        setZone("H")
        /*
        if zoneHButton.isSelected {
            zoneHButton.isSelected = false
        } else {
            zoneHButton.isSelected = true
        }
        setChannelZonesMode()
        */
    }
    
    @IBAction func testAction(_ sender: UIButton) {
        testTriggerButton.isSelected = true
        BluetoothManager.instance.sendTestTriggerTo(selectedNR1)
    }
    
    @IBAction func setTamperEnabled(_ sender: UIButton) {
        if tamperStateButton.isSelected {
            tamperStateButton.isSelected = false
        } else {
            tamperStateButton.isSelected = true
        }
        setTamperSettings()
    }
    
    @IBAction func setTamperSensitivityAction(_ sender: UISlider) {
        let sensitivity = tamperSensitivitySlider.value * 100
        if sensitivity < 33 {
            tamperSensitivitySlider.setValue(0, animated: true)
        } else if sensitivity >= 33 && sensitivity < 67 {
            tamperSensitivitySlider.setValue(0.5, animated: true)
        } else if sensitivity >= 67 {
            tamperSensitivitySlider.setValue(1, animated: true)
        }
        setTamperSettings()
    }
    
    func setChannelZonesMode() {
        let channel: UInt8 = UInt8(channelSettingPickerView.selectedRow(inComponent: 0)) + 1
        if modeButton.isCameraMode {
            let zones = getSelectedZones(inCameraMode: true)
            let mode: UInt8 = 0x01
            BluetoothManager.instance.setChannelZoneModeForNR1(selectedNR1, mode: mode, channel: channel, zone: zones)
        } else {
            let zones = getSelectedZones(inCameraMode: false)
            let mode: UInt8 = 0x00
            BluetoothManager.instance.setChannelZoneModeForNR1(selectedNR1, mode: mode, channel: channel, zone: zones)
        }
    }
    
    
    func getSelectedZones(inCameraMode: Bool) -> UInt8 {
        var zones: UInt8 = 0
        if zoneAButton.isSelected {
            zones += 1
        }
        if zoneBButton.isSelected {
            zones += 2
        }
        if zoneCButton.isSelected {
            zones += 4
        }
        if zoneDButton.isSelected {
            zones += 8
        }
        if inCameraMode {
            if zoneEButton.isSelected {
                zones += 16
            }
            if zoneFButton.isSelected {
                zones += 32
            }
            if zoneGButton.isSelected {
                zones += 64
            }
            if zoneHButton.isSelected {
                zones += 128
            }
        }
        return zones
    }
    
    func setTamperSettings() {
        let rawSensitivty = tamperSensitivitySlider.value
        var sensitivty: UInt8
        var state: UInt8
        switch rawSensitivty {
        case 0:
            sensitivty = 0
        case 0.5:
            sensitivty = 1
        case 1:
            sensitivty = 2
        default:
            fatalError("Slider not at specific value")
        }
        if tamperStateButton.isEnabled {
            state = 1
        } else {
            state = 0
        }
        BluetoothManager.instance.setTamperSettingForNR1(selectedNR1, tamperState: state, tamperSensitivity: sensitivty)
    }
    
    func toggleMode() {
        if let nr1Data = CoreDataManager.instance.getNR1WithUUID(uuid: selectedNR1.identifier, context: CoreDataManager.instance.persistentContainer.viewContext),
           var zones = nr1Data.zones {
            if nr1Data.mode == 0x00 {
                BluetoothManager.instance.setChannelZoneModeForNR1(selectedNR1, mode: 0x01, channel: UInt8(nr1Data.channel), zone: zones.zonesByte)
            } else {
                var channel = nr1Data.channel
                if channel > 32 {
                    channel = 32
                }
                zones.removeAll { (char) -> Bool in
                    "EFGH".contains(char)
                }
                BluetoothManager.instance.setChannelZoneModeForNR1(selectedNR1, mode: 0x00, channel: UInt8(nr1Data.channel), zone: zones.zonesByte)
            }
        }
    }
    
    func setChannel(_ channel: Int) {
        if let nr1Data = CoreDataManager.instance.getNR1WithUUID(uuid: selectedNR1.identifier, context: CoreDataManager.instance.persistentContainer.viewContext),
           let zones = nr1Data.zones {
            BluetoothManager.instance.setChannelZoneModeForNR1(selectedNR1, mode: UInt8(nr1Data.mode), channel: UInt8(channel), zone: zones.zonesByte)
        }
    }
    
    func channelUp() {
        if let nr1Data = CoreDataManager.instance.getNR1WithUUID(uuid: selectedNR1.identifier, context: CoreDataManager.instance.persistentContainer.viewContext),
           let zones = nr1Data.zones {
            BluetoothManager.instance.setChannelZoneModeForNR1(selectedNR1, mode: UInt8(nr1Data.mode), channel: UInt8(nr1Data.channel + 1), zone: zones.zonesByte)
        }
    }
    
    func channelDown() {
        if let nr1Data = CoreDataManager.instance.getNR1WithUUID(uuid: selectedNR1.identifier, context: CoreDataManager.instance.persistentContainer.viewContext),
           let zones = nr1Data.zones {
            BluetoothManager.instance.setChannelZoneModeForNR1(selectedNR1, mode: UInt8(nr1Data.mode), channel: UInt8(nr1Data.channel - 1), zone: zones.zonesByte)
        }
    }
    
    func setZone(_ zone: String) {
        if let nr1Data = CoreDataManager.instance.getNR1WithUUID(uuid: selectedNR1.identifier, context: CoreDataManager.instance.persistentContainer.viewContext),
           let currentZonesString = nr1Data.zones,
           let selectedZone = zoneBytes[zone] {
                var currentZones = currentZonesString.zonesByte
                if currentZonesString.contains(zone) {
                    currentZones = currentZones - UInt8(selectedZone)
                } else {
                    currentZones = currentZones + UInt8(selectedZone)
                }
            BluetoothManager.instance.setChannelZoneModeForNR1(selectedNR1, mode: UInt8(nr1Data.mode), channel: UInt8(nr1Data.channel), zone: currentZones)
            
        }
    }
    
    func setChannelZoneModeSettings(selectedNR1Data: NR1) {
        channelSettingPickerView.selectRow(Int(selectedNR1Data.channel) - 1, inComponent: 0, animated: true)
        if Int(selectedNR1Data.mode) == 0 {
            modeButton.isCameraMode = false
            zoneEButton.isEnabled = false
            zoneFButton.isEnabled = false
            zoneGButton.isEnabled = false
            zoneHButton.isEnabled = false
        } else {
            modeButton.isCameraMode = true
            zoneEButton.isEnabled = true
            zoneFButton.isEnabled = true
            zoneGButton.isEnabled = true
            zoneHButton.isEnabled = true
        }
        if let zones = selectedNR1Data.zones {
            if zones.contains("A") {
                zoneAButton.isSelected = true
            } else {
                zoneAButton.isSelected = false
            }
            if zones.contains("B") {
                zoneBButton.isSelected = true
            } else {
                zoneBButton.isSelected = false
            }
            if zones.contains("C") {
                zoneCButton.isSelected = true
            } else {
                zoneCButton.isSelected = false
            }
            if zones.contains("D") {
                zoneDButton.isSelected = true
            } else {
                zoneDButton.isSelected = false
            }
            if zones.contains("E") {
                zoneEButton.isSelected = true
            } else {
                zoneEButton.isSelected = false
            }
            if zones.contains("F") {
                zoneFButton.isSelected = true
            } else {
                zoneFButton.isSelected = false
            }
            if zones.contains("G") {
                zoneGButton.isSelected = true
            } else {
                zoneGButton.isSelected = false
            }
            if zones.contains("H") {
                zoneHButton.isSelected = true
            } else {
                zoneHButton.isSelected = false
            }
        }
    }
    
    func setTamperSettings(selectedNR1Data: NR1) {
        if Int(selectedNR1Data.tamperState) == 0 {
           tamperStateButton.isSelected = false
        } else {
           tamperStateButton.isSelected = true
        }
        switch selectedNR1Data.tamperSetting {
        case 0:
           tamperSensitivitySlider.value = 0
        case 1:
           tamperSensitivitySlider.value = 0.5
        case 2:
           tamperSensitivitySlider.value = 1
        default:
           tamperSensitivitySlider.value = 0
        }
    }
    
    func enableChannelUI() {
        channelView.setShadow(on: true)
        zoneView.setShadow(on: true)
        channelViewTitle.isEnabled = true
        zoneViewTitle.isEnabled = true
        modeButton.isEnabled = true
        channelSettingPickerView.isUserInteractionEnabled = true
        channelUpButton.isEnabled = true
        channelDownButton.isEnabled = true
        zoneAButton.isEnabled = true
        zoneBButton.isEnabled = true
        zoneCButton.isEnabled = true
        zoneDButton.isEnabled = true
        zoneEButton.isEnabled = true
        zoneFButton.isEnabled = true
        zoneGButton.isEnabled = true
        zoneHButton.isEnabled = true
    }
    
    func enableTamperUI() {
        tamperView.setShadow(on: true)
        tamperViewTitle.isEnabled = true
        tamperStateButton.isEnabled = true
        tamperSensitivitySlider.isEnabled = true
    }
    
    func disableUI() {
        deviceNameLabel.textColor = .lightGray
        channelView.setShadow(on: false)
        zoneView.setShadow(on: false)
        tamperView.setShadow(on: false)
        channelViewTitle.isEnabled = false
        zoneViewTitle.isEnabled = false
        tamperViewTitle.isEnabled = false
        modeButton.isEnabled = false
        channelSettingPickerView.isUserInteractionEnabled = false
        channelUpButton.isEnabled = false
        channelDownButton.isEnabled = false
        zoneAButton.isEnabled = false
        zoneBButton.isEnabled = false
        zoneCButton.isEnabled = false
        zoneDButton.isEnabled = false
        zoneEButton.isEnabled = false
        zoneFButton.isEnabled = false
        zoneGButton.isEnabled = false
        zoneHButton.isEnabled = false
        tamperStateButton.isEnabled = false
        tamperSensitivitySlider.isEnabled = false
        testTriggerButton.isEnabled = false
        deviceImageView.setConnected(false)
        firmwareUpdateButton.isEnabled = false
    }
    
    func setUpUI() {
        channelSettingPickerView.transform = CGAffineTransform(rotationAngle: 270 * (.pi/180))
        channelViewTitle.textColor = .systemBlue
        zoneViewTitle.textColor = .systemGreen
        tamperViewTitle.textColor = .systemYellow
        if let selectedNR1Data = CoreDataManager.instance.getNR1WithUUID(uuid: selectedNR1.identifier, context: CoreDataManager.instance.persistentContainer.newBackgroundContext()) {
            deviceNameLabel.text = selectedNR1Data.modelNumber
            setChannelZoneModeSettings(selectedNR1Data: selectedNR1Data)
            setTamperSettings(selectedNR1Data: selectedNR1Data)
            if let uuid = selectedNR1Data.uuid {
                if FirmwareManager.instance.deviceUUIDsToBeUpdated.contains(uuid) {
                    firmwareUpdateButton.isEnabled = true
                } else {
                    firmwareUpdateButton.isEnabled = false
                }
            }
        }
        deviceImageView.setConnected(true)
    }
    
    func didActionAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FirmwareUpdateSegue" {
            // Is segueing to advanced settings, pass along device.
                if let controller = segue.destination as? FirmwareUpdateViewController {
                    controller.selectedNR1 = selectedNR1
            }
        }
    }
    

}

extension DeviceSettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if modeButton.isCameraMode {
            return cameraModeChannelPickerData.count
        } else {
            return flashModeChannelPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setChannel(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "ArialMT", size: 32)
        titleLabel.textAlignment = NSTextAlignment.center
        if modeButton.isCameraMode {
            titleLabel.text = cameraModeChannelPickerData[row]
        } else {
            titleLabel.text = flashModeChannelPickerData[row]
        }
        titleLabel.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))
        return titleLabel
    }
}

extension DeviceSettingsViewController: SettingsDelegate {
    func didUpdateChannelSettingsFor(nr1: CBPeripheral, channel: Int, zones: String, mode: Int) {
        if nr1 != selectedNR1 {return}
        if channelFirstRead {
            enableChannelUI()
            channelFirstRead = false
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        channelSettingPickerView.selectRow(channel - 1, inComponent: 0, animated: true)
        if zones.contains("A") {
            zoneAButton.isSelected = true
        } else {
            zoneAButton.isSelected = false
        }
        if zones.contains("B") {
            zoneBButton.isSelected = true
        } else {
            zoneBButton.isSelected = false
        }
        if zones.contains("C") {
            zoneCButton.isSelected = true
        } else {
            zoneCButton.isSelected = false
        }
        if zones.contains("D") {
            zoneDButton.isSelected = true
        } else {
            zoneDButton.isSelected = false
        }
        if zones.contains("E") {
            zoneEButton.isSelected = true
        } else {
            zoneEButton.isSelected = false
        }
        if zones.contains("F") {
            zoneFButton.isSelected = true
        } else {
            zoneFButton.isSelected = false
        }
        if zones.contains("G") {
            zoneGButton.isSelected = true
        } else {
            zoneGButton.isSelected = false
        }
        if zones.contains("H") {
            zoneHButton.isSelected = true
        } else {
            zoneHButton.isSelected = false
        }
        if mode == 0x01 {
            modeButton.isCameraMode = true
            zoneEButton.isEnabled = true
            zoneFButton.isEnabled = true
            zoneGButton.isEnabled = true
            zoneHButton.isEnabled = true
        } else {
            modeButton.isCameraMode = false
            zoneEButton.isEnabled = false
            zoneFButton.isEnabled = false
            zoneGButton.isEnabled = false
            zoneHButton.isEnabled = false
        }
        channelSettingPickerView.reloadComponent(0)
    }
    
    func didUpdateTamperSettingsFor(nr1: CBPeripheral, state: Int, sensitivity: Int) {
        if nr1 != selectedNR1 {return}
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if state == 0 {
            tamperStateButton.isSelected = false
        } else {
            tamperStateButton.isSelected = true
        }
        switch sensitivity {
        case 0:
            tamperSensitivitySlider.value = 0
        case 1:
            tamperSensitivitySlider.value = 0.5
        case 2:
            tamperSensitivitySlider.value = 1
        default:
            tamperSensitivitySlider.value = 0
        }
    }
    
    func didUpdateTriggerTestFor(nr1: CBPeripheral) {
        if nr1 != selectedNR1 {return}
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        testTriggerButton.isSelected = false
    }
    
    func didConnectTo(nr1: CBPeripheral) {
        if nr1 != selectedNR1 {return}
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        deviceImageView.setConnected(true)
        connectButton.connectionState = .connected
        if FirmwareManager.instance.deviceUUIDsToBeUpdated.contains(nr1.identifier.uuidString){
            firmwareUpdateButton.isEnabled = true
        } else {
            firmwareUpdateButton.isEnabled = false
        }
    }
    
    func failedToConnectTo(nr1: CBPeripheral) {
        if nr1 != selectedNR1 {return}
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        didActionAlert(title: "Failed to Connect", message: "Could not connect to NR1. Please ensure device is turned on and in range.")
        connectButton.connectionState = .disconnected
    }
    
    func didDisconnectFrom(nr1: CBPeripheral) {
        if nr1 != selectedNR1 {return}
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        connectButton.connectionState = .disconnected
        channelFirstRead = true
        tamperFirstRead = true
        disableUI()
    }
    
    func didFindTestCharacteristicFor(nr1: CBPeripheral) {
        if nr1 != selectedNR1 {return}
        testTriggerButton.isEnabled = true
    }
    
    func didReadModelNumberFor(nr1: CBPeripheral, model: String) {
        if nr1 != selectedNR1 {return}
        deviceNameLabel.textColor = .darkGray
        deviceNameLabel.text = model
    }
}

extension String {
    
    var zonesByte: UInt8 {
        get {
            var zones: UInt8 = 0
            var currentByte: UInt8 = 1
            for zone in ["A", "B", "C", "D", "E", "F", "G", "H"] {
                if self.contains(zone) {
                    zones += currentByte
                }
                if zone != "H" {
                    currentByte = currentByte * 2
                }
            }
            return zones
        }
    }
}
