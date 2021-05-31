//
//  InventoryViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/12/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//

import UIKit
import CoreBluetooth
import Amplify
import AmplifyPlugins

class InventoryViewController: UIViewController {
    
    // Storyboard Outlets
    @IBOutlet weak var inventoryTableView: UITableView!
    @IBOutlet weak var myPocketWizardsLabel: UILabel!
    @IBOutlet weak var discoverButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet var wholeView: UIView!
    
    var popUpScanViewController: ScanPopUpViewController?
    // Inventory Presenter
    var inventory: Inventory = Inventory()
    var inventoryTableViewDataSource: InventoryTableViewDataSource = InventoryTableViewDataSource()
    var firmwareRetriever: FirmwareRetriever = FirmwareRetriever()
    
    // Latest Firmware Rev Name
    var firmwareString: String?
    
    let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    /*****************View Controller Delegate Methods*********************/
    override func viewDidLoad() {
        // Load View
        super.viewDidLoad()
        
        self.navigationItem.titleView = PWLogoView(frame: CGRect(x: 0, y: 0, width: 270, height: 35))
        // Assign view controller as table view delegate and data source
        inventoryTableView.delegate = self
        inventoryTableView.dataSource = inventoryTableViewDataSource
        inventoryTableView.reloadData()
        
        // Inventory label font
        myPocketWizardsLabel.font = UIFont(name: "Arial-BoldMT", size: 22)
        
        NotificationCenter.default.addObserver(self, selector: #selector(centralManagerDidUpdateState), name: NSNotification.Name(rawValue: centralManagerDidUpdateStateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothOff), name: NSNotification.Name(rawValue: bluetoothOffNotification), object: nil)
        //firmwareRetriever.retrieveFirmwareList(delegate: self)
    }
    
    /************BUG: saved peripherals will not show until the view is revisited no matter where the get saved peripherals and reload table calls are****/
    
    override func viewWillAppear(_ animated: Bool) {
        // Reload inventory
        inventoryTableView.reloadData()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        inventoryTableView.reloadData()
        // Check for firmware updates if haven't already
        /*
        if (!inventory.checkedUpdates()) {
            // Put on global queue so as not to hold up main thread
            DispatchQueue.global().async {
                let devices = self.inventory.checkForUpdates()
                let latestFirmware = self.inventory.getLatestFirmware()
                self.firmwareString = latestFirmware
                // If new firmware is available present "Updates Avaialable" alert
                if devices != "" {
                    // Put UI related tasks back on main thread
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Firmware Updates Available", message: latestFirmware + " is now available and is compatible with the following devices: " + devices + ". Please connect to update.", preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "Okay", style: .default) { (okayAction) in
                            alert.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(okayAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
 */
    }
    
    override func viewWillDisappear(_ animated: Bool) {}
 
    // Prepare for storyboard segue to device settings
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DeviceSettings" {
            if let indexPath = inventoryTableView.indexPathForSelectedRow {
                if let controller = segue.destination as? SettingsViewController {
                    // Create settings object in new view controller with index from row selection and pass along firmware name
                    controller.settings = Settings(index: indexPath.row)
                    controller.latestFirmware = inventory.latestFirmwareName
                    controller.firmwareString = self.firmwareString
                }
            }
        }
    }
    
    
    /*******************Storyboard Actions*********************/
    func getEscapeHatch() {
        do {
            let plugin = try Amplify.Analytics.getPlugin(for: "awsPinpointAnalyticsPlugin") as! AWSPinpointAnalyticsPlugin
            let awsPinpoint = plugin.getEscapeHatch()
            
        } catch {
            print("Get escape hatch failed with error - \(error)")

        }
        
    }
    
    func uploadData() {
        let dataString = "Example file contents"
        let data = dataString.data(using: .utf8)!
        _ = Amplify.Storage.uploadData(key: "myKey", data: data,
            progressListener: { progress in
                print("Progress: \(progress)")
            }, resultListener: { (event) in
                switch event {
                case .success(let data):
                    print("Completed: \(data)")
                case .failure(let storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        })
    }
    
    func uploadFiles() {
        let dataString = "My Data"
        let data = dataString.data(using: .utf8)!
        _ = Amplify.Storage.uploadData(key: "myKey", data: data) { (event) in
            switch event {
            case .success(let data):
                print("Completed: \(data)")
            case .failure(let storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
        }
    }
    }
    func listFiles() {
        _ = Amplify.Storage.list { event in
            switch event {
            case let .success(listResult):
                print("Completed")
                listResult.items.forEach { item in
                    print("Key: \(item.key)")
                }
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        }
    }
    
    // Prepare for unwind segue from Settings controller
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {}
 
    // On edit button pressed
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        // Do nothing if nothing in inventory
        if inventory.getSavedPeripheralsLength() < 1 {
            return
        }
        // Change edit mode on/off and reload table into corresponding view cell type
        if self.inventory.getEditMode() {
            self.inventory.setEditMode(state: false)
            self.editButton.title = "Edit"
            self.inventoryTableView.reloadData()
        } else {
            self.inventory.setEditMode(state: true)
            self.editButton.title = "Done"
            self.inventoryTableView.reloadData()
        }
    }
    
    @IBAction func discoverAction(_ sender: UIButton) {
        
        mediumGenerator.impactOccurred()
        popUpScanViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "deviceScanPopUpID") as? ScanPopUpViewController
        self.addChild(popUpScanViewController!)
        popUpScanViewController!.view.frame = UIScreen.main.bounds
        self.view.addSubview(popUpScanViewController!.view)
        popUpScanViewController!.didMove(toParent: self)
 
        NotificationCenter.default.addObserver(self, selector: #selector(deviceReadyToAdd), name: NSNotification.Name(deviceReadyToAddNotification), object: nil)
    }
    
    /****************Objective-C Style Selector Methods************/
    @objc func bluetoothOff() {
        let alert = UIAlertController(title: "Bluetooth Off", message: "Please turn on Bluetooth to see your inventory and manage your PocketWizards.", preferredStyle: .alert)
        // Create "cancel" action
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (cancelAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        // Add remove and cancel actions and present
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
        inventoryTableView.isUserInteractionEnabled = false
        inventoryTableView.reloadData()
    }
    
    @objc private func centralManagerDidUpdateState() {
        inventoryTableView.isUserInteractionEnabled = true
        inventoryTableView.reloadData()
    }
    
    @objc private func deviceReadyToAdd() {
        
        popUpScanViewController?.willMove(toParent: nil)
        heavyGenerator.impactOccurred()
        UIView.animate(withDuration: 0.25, animations: {
            self.popUpScanViewController?.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popUpScanViewController?.view.alpha = 0.0
        }) { (finished: Bool) in
            if (finished) {
                self.popUpScanViewController?.view.removeFromSuperview()
                self.popUpScanViewController?.removeFromParent()
                self.inventoryTableView.reloadData()
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(deviceReadyToAddNotification), object: nil)
            }
        }
    }
}

extension InventoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go to device settings page
        performSegue(withIdentifier: "DeviceSettings", sender: nil)
    }
}
/*
extension InventoryViewController: FirmwareRetrieverDelegate {
    func didRetrieveFirmwareUpdate(firmwareUpdate: FirmwareUpdate) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Firmware Update Available", message: "Firmware version " + firmwareUpdate.version + " is available for the following product: " + firmwareUpdate.device, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default) { (okayAction) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
*/
