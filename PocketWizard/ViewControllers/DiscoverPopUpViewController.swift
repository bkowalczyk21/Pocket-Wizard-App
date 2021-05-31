//
//  DiscoverPopUpViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/6/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit
import CoreBluetooth

class DiscoverPopUpViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var discoveredDevicesTableView: UITableView!
    @IBOutlet weak var scanActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var popUpView: UIView!

    private var connecting: Bool = false
    private var leavingParent: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        discoveredDevicesTableView.delegate = self
        discoveredDevicesTableView.dataSource = self
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        popUpView.layer.cornerRadius = 20
        titleLabel.font = .arial22
        scanActivityIndicator.isHidden = true
        scanActivityIndicator.stopAnimating()
        showAnimate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startDeviceDiscovery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopNewDeviceDiscovery()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if leavingParent {
            leavingParent = false
            connecting = false
            if let parentVC = parent as? HomeViewController {
                parentVC.savedNR1sTableView.reloadData()
            }
        }
    }
    
    @IBAction func closePopUpAction(_ sender: UIButton) {
        removeAnimate()
    }
    
    @IBAction func refreshAction(_ sender: UIButton) {
        startDeviceDiscovery()
    }
    
    func showAnimate() {
        view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        view.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        }
    }
    
    func removeAnimate() {
        leavingParent = true
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished: Bool) in
            if (finished) {
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        }
    }
    
    func startDeviceDiscovery() {
        scanActivityIndicator.isHidden = false
        scanActivityIndicator.startAnimating()
        BluetoothManager.instance.initiateNewDeviceDiscovery(delegate: self)
        discoveredDevicesTableView.reloadData()
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            self.stopNewDeviceDiscovery()
        }
    }
    
    func stopNewDeviceDiscovery() {
        DispatchQueue.main.async {
            self.scanActivityIndicator.isHidden = true
            self.scanActivityIndicator.stopAnimating()
        }
        BluetoothManager.instance.terminateNewDeviceDiscovery()
    }
    
    func presentConnectionFailedAlert(nr1: CBPeripheral) {
        let alert = UIAlertController(title: "Connection Failed", message: "Could not connect to PocketWizard. Please ensure device is turned on, in range and advertising.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (okayAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (retryAction) in
            alert.dismiss(animated: true) {
                self.connecting = true
                BluetoothManager.instance.connect(toNR1: nr1)
            }
        }
        alert.addAction(okayAction)
        alert.addAction(retryAction)
        present(alert, animated: true, completion: nil)
    }

}

extension DiscoverPopUpViewController: ScanningDelegate {
    func didFailToConnectTo(nr1: CBPeripheral) {
        connecting = false
        discoveredDevicesTableView.reloadData()
        presentConnectionFailedAlert(nr1: nr1)
    }
    
    func didUpdateFoundNR1s() {
        print("New device discovered")
        discoveredDevicesTableView.reloadData()
    }
    
    func didConnectToNR1(nr1: CBPeripheral) {
        print("connected to: " + nr1.debugDescription)
        connecting = false
        removeAnimate()
    }
}

extension DiscoverPopUpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !connecting {
            connecting = true
            stopNewDeviceDiscovery()
            let nr1 = BluetoothManager.instance.discoveredNR1s[indexPath.row]
            BluetoothManager.instance.connect(toNR1: nr1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if nr1.state != .connected {
                    BluetoothManager.instance.cancelConnection(toNR1: nr1)
                    self.connecting = false
                    self.presentConnectionFailedAlert(nr1: nr1)
                }
            }
        }
    }
}

extension DiscoverPopUpViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothManager.instance.discoveredNR1s.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PopUpScanTableViewCellID", for: indexPath) as? PopUpScanTableViewCell else {fatalError("Dequeued cell not an instance of InventoryTableViewCell")}
        let nr1 = BluetoothManager.instance.discoveredNR1s[indexPath.row]
        cell.deviceLabel.text = nr1.name ?? "PW NR1"
        if nr1.state == .connecting {
            cell.setConnectingAnimation(true)
        } else {
            cell.setConnectingAnimation(false)
        }
        return cell
    }
}
