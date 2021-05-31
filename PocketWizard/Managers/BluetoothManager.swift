//
//  BluetoothManager.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/21/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol SettingsDelegate {
    func didUpdateChannelSettingsFor(nr1: CBPeripheral, channel: Int, zones: String, mode: Int)
    func didUpdateTamperSettingsFor(nr1: CBPeripheral, state: Int, sensitivity: Int)
    func didUpdateTriggerTestFor(nr1: CBPeripheral)
    func didConnectTo(nr1: CBPeripheral)
    func failedToConnectTo(nr1: CBPeripheral)
    func didDisconnectFrom(nr1: CBPeripheral)
    func didReadModelNumberFor(nr1: CBPeripheral, model: String)
    func didFindTestCharacteristicFor(nr1: CBPeripheral)
}

protocol ScanningDelegate {
    func didUpdateFoundNR1s()
    func didConnectToNR1(nr1: CBPeripheral)
    func didFailToConnectTo(nr1: CBPeripheral)
}

protocol FirmwareUpdateDelegate {
    func didInitiateUpdate()
    func didUpdateFileLocation(percentageDouble: Double)
    func didCompleteUpload()
    func didCompleteInstallation(updatedFirmwareRevision: String)
    func firmwareUpdateFailed(error: String)
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    enum FirmwareUpdateState {
        case notUpdating
        case initiatingUpload
        case uploading
        case terminatingUpload
        case installing
    }
    
    enum OTAControlBytes: UInt8 {
        case beginUpload = 0x00
        case terminateUpload = 0x03
    }
    
    static let instance = BluetoothManager()
    
    private let centralManager: CBCentralManager
    private var scanningDelegate: ScanningDelegate?
    private var settingsDelegate: SettingsDelegate?
    private var firmwareUpdateDelegate: FirmwareUpdateDelegate?
    //private var selectedNR1: CBPeripheral?
    private var firmwareUpdateState: FirmwareUpdateState = .notUpdating
    private var firmwareFileSize: Int!
    private var fileLocation: Int!
    private var packetLength: Int!
    private var inputStream: InputStream!
    private var deviceUpdating: CBPeripheral!
    
    private(set) var discoveredNR1s = [CBPeripheral]() {
        didSet {
            scanningDelegate?.didUpdateFoundNR1s()
        }
    }
    
    private(set) var savedNR1s = [CBPeripheral]() {
        didSet {
            NotificationCenter.default.post(name: .didUpdateSavedNR1s, object: nil)
        }
    }
    
    private let DEVICE_INFORMATION_SERVICE_UUID = CBUUID(string: "180A")
    private let MANUFACTURER_NAME_CHARACTERISTIC_UUID = CBUUID(string: "2A29")
    private let MODEL_NUMBER_CHARACTERISTIC_UUID = CBUUID(string: "2A24")
    private let FIRMWARE_REVISISON_CHARACTERISTIC_UUID = CBUUID(string: "2A26")
    
    private let NR1_CONTROL_SERVICE_UUID = CBUUID(string: "91EA7E41-A26F-44D4-B4CC-A00422D870AC")
    private let CHANNEL_SETTING_CHARACTERISTIC_UUID = CBUUID(string: "AC606CB7-B8E7-4108-A962-B96736EB01D1")
    private let TAMPER_SETTING_CHARACTERISTIC_UUID = CBUUID(string: "D0512A4C-9329-11EA-BB37-0242AC130002")
    private let ACCELEROMETER_READING_CHARACTERISTIC_UUID = CBUUID(string: "86B764BE-E328-4EFF-9BCC-063878B32A35")
    private let TRIGGER_CHARACTERSTIC_UUID = CBUUID(string: "291DD0C8-9F69-4CAA-82D1-90AD0C658118")
    private let CONTACT_TIME_CHARACTERISTIC_UUID = CBUUID(string: "CC82CE42-ADEF-4F5E-BF73-97946297C002")
    
    private let OTA_SERVICE_UUID = CBUUID(string: "1D14D6EE-FD63-4FA1-BFA4-8F47B42119F0")
    private let OTA_CONTROL_CHARACTERISTIC_UUID = CBUUID(string: "F7BF3564-FB6D-4E53-88A4-5E37E0326063")
    private let OTA_DATA_CHARACTERISTIC_UUID = CBUUID(string: "984227F3-34FC-4045-A5D0-2C581F81A153")
    
    
    override private init() {
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        centralManager.delegate = self
    }
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            var uuids: [UUID] = []
            if let savedNR1s = CoreDataManager.instance.getSavedNR1s(context: CoreDataManager.instance.persistentContainer.viewContext) {
                print(savedNR1s.description)
                for eachNR1 in savedNR1s {
                    if let uuid = eachNR1.uuid {
                        uuids.append(UUID(uuidString: uuid)!)
                    }
                }
            }
            let unorderedNR1s = centralManager.retrievePeripherals(withIdentifiers: uuids)
            for nr1 in unorderedNR1s {
                if nr1.state == .connected {
                    savedNR1s.insert(nr1, at: 0)
                } else {
                    savedNR1s.append(nr1)
                }
            }
            NotificationCenter.default.post(name: .centralManagerUpdatedToBluetoothOn, object: nil)
        case .poweredOff:
            NotificationCenter.default.post(name: .centralManagerUpdatedToBluetoothOff, object: nil, userInfo: ["Message": "Please ensure Bluetooth is powered on."])
        case .unsupported:
            NotificationCenter.default.post(name: .centralManagerUpdatedToBluetoothOff, object: nil, userInfo: ["Message": "Bluetooth is unsupported on this device."])
        case .unauthorized:
            NotificationCenter.default.post(name: .centralManagerUpdatedToBluetoothOff, object: nil, userInfo: ["Message": "Please authorize Bluetooth for the PocketWizard app."])
        default:
            NotificationCenter.default.post(name: .centralManagerUpdatedToBluetoothOff, object: nil, userInfo: ["Message": ""])

        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral == deviceUpdating {
            if firmwareUpdateState == .installing {
                connect(toNR1: peripheral)
            }
            return
        }
        if peripheral.name == "NR1" {
            if !discoveredNR1s.contains(peripheral) {
                discoveredNR1s.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if !savedNR1s.contains(peripheral) {
            print("Connected to new NR1")
            CoreDataManager.instance.createNR1WithPeripheral(peripheral)
            savedNR1s.insert(peripheral, at: 0)
            print(scanningDelegate.debugDescription)
            scanningDelegate?.didConnectToNR1(nr1: peripheral)
            scanningDelegate = nil
        } else {
            if let index = savedNR1s.firstIndex(of: peripheral) {
                savedNR1s.remove(at: index)
                savedNR1s.insert(peripheral, at: 0)
            }
            settingsDelegate?.didConnectTo(nr1: peripheral)
        }
        peripheral.delegate = self
        peripheral.discoverServices([DEVICE_INFORMATION_SERVICE_UUID, NR1_CONTROL_SERVICE_UUID, OTA_SERVICE_UUID])
       
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if peripheral == deviceUpdating {
            firmwareUpdateState = .notUpdating
            deviceUpdating = nil
            firmwareUpdateDelegate?.firmwareUpdateFailed(error: "Could not reconnect to device. Firmware update installation may still be complete.")
            return
        }
        if savedNR1s.contains(peripheral) {
            settingsDelegate?.failedToConnectTo(nr1: peripheral)
        } else {
            scanningDelegate?.didFailToConnectTo(nr1: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == deviceUpdating {
            if firmwareUpdateState != .terminatingUpload {
                firmwareUpdateState = .notUpdating
                deviceUpdating = nil
                firmwareUpdateDelegate?.firmwareUpdateFailed(error: "Device disconnected unexpectedly. Please ensure your PocketWizard is with five feet of your phone throughout the upload.")
            } else {
                firmwareUpdateState = .installing
            }
        }
        if let index = savedNR1s.firstIndex(of: peripheral) {
            savedNR1s.remove(at: index)
            savedNR1s.append(peripheral)
        }
        settingsDelegate?.didDisconnectFrom(nr1: peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach({ (service) in
            switch service.uuid {
            case DEVICE_INFORMATION_SERVICE_UUID:
                peripheral.discoverCharacteristics(nil, for: service)
            case NR1_CONTROL_SERVICE_UUID:
                peripheral.discoverCharacteristics(nil, for: service)
            case OTA_SERVICE_UUID:
                peripheral.discoverCharacteristics(nil, for: service)
            default:
                print("Discovered unrecognized service: \(service.uuid)")
            }
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        switch service.uuid {
        case DEVICE_INFORMATION_SERVICE_UUID:
            service.characteristics?.forEach({ (characteristic) in
                switch characteristic.uuid {
                case MANUFACTURER_NAME_CHARACTERISTIC_UUID:
                    peripheral.readValue(for: characteristic)
                case MODEL_NUMBER_CHARACTERISTIC_UUID:
                    peripheral.readValue(for: characteristic)
                case FIRMWARE_REVISISON_CHARACTERISTIC_UUID:
                    peripheral.readValue(for: characteristic)
                default:
                    print("Discovered unrecognized characteristic: \(characteristic.uuid) in DIS.")
                }
            })
        case NR1_CONTROL_SERVICE_UUID:
            service.characteristics?.forEach({ (characteristic) in
                switch characteristic.uuid {
                case CHANNEL_SETTING_CHARACTERISTIC_UUID:
                    peripheral.readValue(for: characteristic)
                case TAMPER_SETTING_CHARACTERISTIC_UUID:
                    peripheral.readValue(for: characteristic)
                case ACCELEROMETER_READING_CHARACTERISTIC_UUID:
                    peripheral.setNotifyValue(true, for: characteristic)
                case TRIGGER_CHARACTERSTIC_UUID:
                    settingsDelegate?.didFindTestCharacteristicFor(nr1: peripheral)
                default:
                    print("Discovered unrecognized characteristic: \(characteristic.uuid) in NR1CS.")
                }
            })
        default:
            print("Discovered service: \(service.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            if peripheral == deviceUpdating {
                firmwareUpdateState = .notUpdating
                deviceUpdating = nil
            }
            print("Error writing value for: \(characteristic.uuid) \(String(describing: error))")
            NotificationCenter.default.post(name: .errorWriting, object: nil)
            return
        }
        switch characteristic.uuid {
        case CHANNEL_SETTING_CHARACTERISTIC_UUID:
            peripheral.readValue(for: characteristic)
        case TAMPER_SETTING_CHARACTERISTIC_UUID:
            peripheral.readValue(for: characteristic)
        case OTA_CONTROL_CHARACTERISTIC_UUID:
            guard peripheral == deviceUpdating else {return}
            if firmwareUpdateState == .initiatingUpload {
                prepareFirmwareImageUpload()
            } else if firmwareUpdateState == .terminatingUpload {
                firmwareUpdateDelegate?.didCompleteUpload()
                cancelConnection(toNR1: peripheral)
            }
        case OTA_DATA_CHARACTERISTIC_UUID:
            guard peripheral == deviceUpdating else {return}
            guard firmwareUpdateState == .uploading else { return }
            fileLocation += packetLength
            firmwareUpdateDelegate?.didUpdateFileLocation(percentageDouble: Double(fileLocation)/Double(firmwareFileSize))
            uploadFirmwareImage()
        default:
            print("Wrote value for: \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            switch characteristic.service.uuid {
            case DEVICE_INFORMATION_SERVICE_UUID:
                switch characteristic.uuid {
                case MANUFACTURER_NAME_CHARACTERISTIC_UUID:
                    if let manufacturerName = data.stringUTF8Encoded {
                        CoreDataManager.instance.updateManufacturerNameFor(peripheral.identifier, manufacturerName: manufacturerName)
                    }
                case MODEL_NUMBER_CHARACTERISTIC_UUID:
                    if let modelNumber = data.stringUTF8Encoded {
                        CoreDataManager.instance.updateModelNumberFor(peripheral.identifier, modelNumber: modelNumber)
                        settingsDelegate?.didReadModelNumberFor(nr1: peripheral, model: modelNumber)
                    }
                case FIRMWARE_REVISISON_CHARACTERISTIC_UUID:
                    if peripheral == deviceUpdating {
                        if firmwareUpdateState == .installing {
                            firmwareUpdateState = .notUpdating
                            deviceUpdating = nil
                            firmwareUpdateDelegate?.didCompleteInstallation(updatedFirmwareRevision: data.stringUTF8Encoded ?? " ")
                        }
                    }
                    if let firmwareRevision = data.stringUTF8Encoded {
                        CoreDataManager.instance.updateFirmwareRevisionFor(peripheral.identifier, firmwareRevision: firmwareRevision)
                    }
                default:
                    print("Updated value for unrecognized Device Information Service characteristic: \(characteristic.uuid)")
                }
            case NR1_CONTROL_SERVICE_UUID:
                switch characteristic.uuid {
                case CHANNEL_SETTING_CHARACTERISTIC_UUID:
                    if let mode = data.uInt8Array?[0].int16, let channel = data.uInt8Array?[1].int16, let zones = data.uInt8Array?[2].zonesStringByBitMask {
                        CoreDataManager.instance.updateModeFor(peripheral.identifier, mode: mode)
                        CoreDataManager.instance.updateChannelFor(peripheral.identifier, channel: channel)
                        CoreDataManager.instance.updateZonesFor(peripheral.identifier, zones: zones)
                        settingsDelegate?.didUpdateChannelSettingsFor(nr1: peripheral, channel: Int(channel), zones: zones, mode: Int(mode))
                    }
                case TAMPER_SETTING_CHARACTERISTIC_UUID:
                    if let state = data.uInt8Array?[0].int16, let setting = data.uInt8Array?[1].int16 {
                        CoreDataManager.instance.updateTamperStateFor(peripheral.identifier, tamperState: state)
                        CoreDataManager.instance.updateTamperSettingFor(peripheral.identifier, tamperSetting: setting)
                        settingsDelegate?.didUpdateTamperSettingsFor(nr1: peripheral, state: Int(state), sensitivity: Int(setting))
                    }
                case ACCELEROMETER_READING_CHARACTERISTIC_UUID:
                    print("Read accelerometer characteristic")
                case TRIGGER_CHARACTERSTIC_UUID:
                    settingsDelegate?.didUpdateTriggerTestFor(nr1: peripheral)
                default:
                    print("Updated value for unrecognized NR1 Control Service characteristic: \(characteristic.uuid)")
                }
            default:
                print(characteristic.service.description)
            }
        }
    }
    
    func removeDeviceFromSavedNR1s(peripheral: CBPeripheral) {
        if peripheral.state == .connected {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        if let index = savedNR1s.firstIndex(of: peripheral) {
            savedNR1s.remove(at: index)
        }
        CoreDataManager.instance.removeNR1WithUUID(peripheral.identifier)
    }
    
    // MARK: - Bluetooth Commands
    
    func initiateNewDeviceDiscovery(delegate: ScanningDelegate) {
        scanningDelegate = delegate
        print(scanningDelegate.debugDescription)
        scanForNR1s()
    }
    
    private func scanForNR1s() {
        guard centralManager.state == .poweredOn else {
            NotificationCenter.default.post(name: .centralManagerUpdatedToBluetoothOff, object: nil, userInfo: ["Message": "Bluetooth must be on to scan for new PocketWizards."])
            return
        }
        discoveredNR1s.forEach { (nr1) in
            centralManager.cancelPeripheralConnection(nr1)
        }
        discoveredNR1s = []
        centralManager.scanForPeripherals(withServices: nil, options:
        [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func terminateNewDeviceDiscovery() {
        //scanningDelegate = nil
        stopScanForNR1s()
    }
    
    private func stopScanForNR1s() {
        centralManager.stopScan()
    }
    
    func connect(toNR1: CBPeripheral) {
        guard centralManager.state == .poweredOn else {
            NotificationCenter.default.post(name: .centralManagerUpdatedToBluetoothOff, object: nil, userInfo: ["Message": "Bluetooth must be on to connect to PocketWizards."])
            return
        }
        centralManager.connect(toNR1, options: nil)
    }
    
    func setSettingsDelegate(delegate: SettingsDelegate) {
        settingsDelegate = delegate
    }
    
    func removeSettingsDelegate() {
        settingsDelegate = nil
    }
    
    func cancelConnection(toNR1: CBPeripheral) {
        centralManager.cancelPeripheralConnection(toNR1)
    }
    
    func setChannelZoneModeForNR1(_ nr1: CBPeripheral, mode: UInt8, channel: UInt8, zone: UInt8) {
        if let channelCharacteristic = channelCharacteristicForNR1(nr1) {
            var data = mode.data
            data.append(channel.data)
            data.append(zone.data)
            writeDataToCharacteristic(data, characteristic: channelCharacteristic)
        }
    }
    
    func setTamperSettingForNR1(_ nr1: CBPeripheral, tamperState: UInt8, tamperSensitivity: UInt8) {
        if let tamperCharacteristic = tamperSettingCharacteristicForNR1(nr1) {
            var data = tamperState.data
            data.append(tamperSensitivity.data)
            writeDataToCharacteristic(data, characteristic: tamperCharacteristic)
        }
    }
    
    func sendTestTriggerTo(_ nr1: CBPeripheral) {
        if let triggerCharacteristic = triggerCharacteristicForNR1(nr1) {
            let value: UInt8 = 0x00
            writeDataToCharacteristic(value.data, characteristic: triggerCharacteristic)
        }
    }
    
    func initiateFirmwareUpdateFor(nr1: CBPeripheral, delegate: FirmwareUpdateDelegate) {
        firmwareUpdateDelegate = delegate
        deviceUpdating = nr1
        firmwareUpdateState = .initiatingUpload
        if let charactersitc = otaControlCharacteristicForNR1(nr1) {
            writeDataToCharacteristic(OTAControlBytes.beginUpload.rawValue.data, characteristic: charactersitc)
        } else {
            firmwareUpdateDelegate?.firmwareUpdateFailed(error: "Device does not support OTA updates.")
        }
    }
    
    func prepareFirmwareImageUpload() {
        firmwareUpdateState = .uploading
        firmwareUpdateDelegate?.didInitiateUpdate()
        packetLength = deviceUpdating.maximumWriteValueLength(for: .withoutResponse)
        if packetLength > 220 {
            packetLength = 220
        }
        fileLocation = 0
        if let imageData = FirmwareManager.instance.firmwareImage {
            firmwareFileSize = imageData.count
            inputStream = InputStream(data: imageData)
            inputStream.open()
            uploadFirmwareImage()
        } else {
            firmwareUpdateDelegate?.firmwareUpdateFailed(error: "Could not retrieve firmware update file.")
        }
        
    }
    
    func uploadFirmwareImage() {
        if inputStream.hasBytesAvailable {
            if let otaDataCharacterstic = otaDataCharacteristicForNR1(deviceUpdating) {
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: packetLength)
                let bytes = inputStream.read(buffer, maxLength: packetLength)
                let bufferPointer = UnsafeMutableBufferPointer(start: buffer, count: bytes)
                let data = Data(buffer: bufferPointer)
                writeDataToCharacteristic(data, characteristic: otaDataCharacterstic)
                buffer.deallocate()
            } else {
                firmwareUpdateDelegate?.firmwareUpdateFailed(error: "Device does not fully support OTA updates.")
            }
        } else {
            inputStream.close()
            finishFirmwareUpload()
        }
    }
    
    func finishFirmwareUpload() {
        firmwareUpdateState = .terminatingUpload
        if let otaControlCharacteristic = otaControlCharacteristicForNR1(deviceUpdating) {
            writeDataToCharacteristic(OTAControlBytes.terminateUpload.rawValue.data, characteristic: otaControlCharacteristic)
        }
    }
    
    func otaServiceForNR1(_ nr1: CBPeripheral) -> CBService? {
        return nr1.services?.filter({ (service) -> Bool in
            return service.uuid == OTA_SERVICE_UUID
            }).first
    }
    
    func otaControlCharacteristicForNR1(_ nr1: CBPeripheral) -> CBCharacteristic? {
        return otaServiceForNR1(nr1)?.characteristics?.filter({ (characteristic) -> Bool in
            return characteristic.uuid == OTA_CONTROL_CHARACTERISTIC_UUID
            }).first
    }
    
    func otaDataCharacteristicForNR1(_ nr1: CBPeripheral) -> CBCharacteristic? {
        return otaServiceForNR1(nr1)?.characteristics?.filter({ (characteristic) -> Bool in
            return characteristic.uuid == OTA_DATA_CHARACTERISTIC_UUID
            }).first
    }
    
    func controlServiceForNR1(_ nr1: CBPeripheral) -> CBService? {
        return nr1.services?.filter({ (service) -> Bool in
            return service.uuid == NR1_CONTROL_SERVICE_UUID
            }).first
    }
    
    func channelCharacteristicForNR1(_ nr1: CBPeripheral) -> CBCharacteristic? {
        return controlServiceForNR1(nr1)?.characteristics?.filter({ (characteristic) -> Bool in
            return characteristic.uuid == CHANNEL_SETTING_CHARACTERISTIC_UUID
            }).first
    }
    
    func triggerCharacteristicForNR1(_ nr1: CBPeripheral) -> CBCharacteristic? {
        return controlServiceForNR1(nr1)?.characteristics?.filter({ (characteristic) -> Bool in
            return characteristic.uuid == TRIGGER_CHARACTERSTIC_UUID
        }).first
    }
    
    func tamperSettingCharacteristicForNR1(_ nr1: CBPeripheral) -> CBCharacteristic? {
        return controlServiceForNR1(nr1)?.characteristics?.filter({ (characteristic) -> Bool in
            return characteristic.uuid == TAMPER_SETTING_CHARACTERISTIC_UUID
        }).first
    }
    
    func writeDataToCharacteristic(_ data: Data, characteristic: CBCharacteristic) {
        guard centralManager.state == .poweredOn else {
            NotificationCenter.default.post(name: .centralManagerUpdatedToBluetoothOff, object: nil, userInfo: ["Message": "Bluetooth must be on to control your PocketWizard."])
            return
        }
        characteristic.service.peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    

    
}

extension Notification.Name {
    static let didUpdateSavedNR1s = Notification.Name(rawValue: "didUpdateSavedNR1s")
    static let errorWriting = NSNotification.Name(rawValue: "errorWritingNotification")
    static let centralManagerUpdatedToBluetoothOn = NSNotification.Name(rawValue: "centralManagerUpdatedToBluetoothOn")
    static let centralManagerUpdatedToBluetoothOff = NSNotification.Name(rawValue: "centralManagerUpdatedToBluetoothOff")
}

extension UInt8 {
    
    var int16: Int16 {
        get {
            return Int16(self)
        }
    }
    
    var data: Data {
        get {
            var value = self
            return Data(bytes: &value, count: MemoryLayout<UInt8>.size)
        }
    }
    var zonesStringByBitMask: String? {
        get {
            var zonesString: String = ""
            var checkBit: UInt8 = 1
            for zone in ["A", "B", "C", "D", "E", "F", "G", "H"] {
                if checkBit & self == checkBit {
                    zonesString.append(zone)
                }
                if zone != "H" {
                    checkBit = checkBit * 2
                }
            }
            return zonesString
        }
    }
}
