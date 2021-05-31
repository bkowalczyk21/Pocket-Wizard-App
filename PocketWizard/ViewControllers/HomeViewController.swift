//
//  HomeViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/4/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit
import CoreBluetooth

class HomeViewController: UIViewController {
    
    @IBOutlet weak var savedNR1sTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.titleView = PWLogoView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        
        savedNR1sTableView.delegate = self
        savedNR1sTableView.dataSource = self
        
        titleLabel.font = .arial22
        
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothIsOn), name: .centralManagerUpdatedToBluetoothOn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothIsOff(_:)), name: .centralManagerUpdatedToBluetoothOff, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(savedNR1sDidChange), name: .didUpdateSavedNR1s, object: nil)
    }
    
    @objc func savedNR1sDidChange() {
        savedNR1sTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savedNR1sTableView.reloadData()
    }
    
    @objc func connectedNR1sDidChange() {
        savedNR1sTableView.reloadData()
    }

    @objc func bluetoothIsOn() {
        savedNR1sTableView.isUserInteractionEnabled = true
        savedNR1sTableView.reloadData()
    }
    
    @objc func bluetoothIsOff(_ notification: NSNotification) {
        var message = "Please ensure this device supports Bluetooth and that it is powered on."
        if let userInfo = notification.userInfo, let errorMessage = userInfo["Message"] as? String {
            message = errorMessage
        }
        let alert = UIAlertController(title: "Bluetooth Off", message: message + " Bluetooth is necessary to load your inventory and manage your PocketWizards.", preferredStyle: .alert)
        // Create "cancel" action
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (cancelAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        // Add remove and cancel actions and present
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
        savedNR1sTableView.isUserInteractionEnabled = false
        savedNR1sTableView.reloadData()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DeviceSettings" {
            if let indexPath = savedNR1sTableView.indexPathForSelectedRow {
                let peripheral = BluetoothManager.instance.savedNR1s[indexPath.row]
                if let viewController = segue.destination as? DeviceSettingsViewController {
                    viewController.selectedNR1 = peripheral
                }
            }
        }
    }
    
    @IBAction func discoverButtonSelected(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        guard let discoverPopUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "deviceScanPopUpID") as? DiscoverPopUpViewController else {fatalError("No VC with given ID")}
        addChild(discoverPopUpViewController)
        discoverPopUpViewController.view.frame = UIScreen.main.bounds
        view.addSubview(discoverPopUpViewController.view)
        discoverPopUpViewController.didMove(toParent: self)
    }

}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DeviceSettings", sender: nil)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothManager.instance.savedNR1s.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryTableViewCell", for: indexPath) as? InventoryTableViewCell else {
            fatalError("Dequeued cell not an instance of InventoryTableViewCell")
        }
        let peripheral = BluetoothManager.instance.savedNR1s[indexPath.row]
        if let nr1 = CoreDataManager.instance.getNR1WithUUID(uuid: peripheral.identifier, context: CoreDataManager.instance.persistentContainer.viewContext) {
            cell.nameLabel.text = nr1.modelNumber
            cell.channelLabel.text = String(nr1.channel)
            let zones = nr1.zones
            if zones == "" {
                cell.zonesLabel.text = "----"
            } else {
                cell.zonesLabel.text = zones
            }
            if nr1.tamperState == 0x01 {
                cell.setTamperStateIndicatorOn()
            } else {
                cell.setTamperStateIndicatorOff()
            }
            if nr1.mode == 0x01 {
                cell.setModeIndicatorToCamera()
            } else {
                cell.setModeIndicatorToFlash()
            }
            if peripheral.state == .connected {
                cell.setCellAsConnected()
            } else {
                cell.setCellAsDisconnected()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            BluetoothManager.instance.removeDeviceFromSavedNR1s(peripheral: BluetoothManager.instance.savedNR1s[indexPath.row])
            //tableView.deleteRows(at: [indexPath], with: .bottom)
        }
    }
}
