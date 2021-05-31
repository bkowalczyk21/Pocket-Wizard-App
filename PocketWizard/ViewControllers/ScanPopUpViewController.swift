//
//  ScanPopUpViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 5/22/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

let popUpViewRemovedNotification = "popUpViewRemovedNotification"

import UIKit
import CoreBluetooth

class ScanPopUpViewController: UIViewController {
    
    @IBOutlet weak var newPocketWizardsLabel: UILabel!
    @IBOutlet weak var scanTableView: UITableView!
    @IBOutlet weak var scanningActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scanView: UIView!
    
    //var addDevice = AddDevice()
    var scanTableViewDataSource: ScanTableViewDataSource!
    //var index: Int?
    //var connecting: Bool = false
    //var connected: Bool = false
    //var deviceConnecting: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanTableViewDataSource = ScanTableViewDataSource(parentController: self)
        scanTableView.delegate = scanTableViewDataSource
        scanTableView.dataSource = scanTableViewDataSource
        
        NotificationCenter.default.addObserver(self, selector: #selector(peripheralsDidUpdate),
        name: NSNotification.Name(rawValue: peripheralsDidUpdateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(peripheralDidConnect), name: NSNotification.Name(rawValue: peripheralDidConnectNotification), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(deviceReadyToAdd), name: NSNotification.Name(deviceReadyToAddNotification), object: nil)

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        // Do any additional setup after loading the view.
        scanView.layer.cornerRadius = 20
    
        
        newPocketWizardsLabel.font = UIFont(name: "Arial-BoldMT", size: 22)
        
        scanningActivityIndicator.isHidden = true
        scanningActivityIndicator.stopAnimating()
        
        showAnimate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startScan()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopScanningUI()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if scanTableViewDataSource.index == nil {
            return
        }
        scanTableViewDataSource.index = nil
        scanTableViewDataSource.connecting = false
        scanTableViewDataSource.connected = true
        scanTableView.reloadData()
        scanTableViewDataSource.popUpScan.addDevice(peripheral: scanTableViewDataSource.deviceConnecting!)
        //removeAnimate()
    }
    
    @IBAction func closePopUpAction(_ sender: UIButton) {
        //self.view.removeFromSuperview()
        self.removeAnimate()
    }
    
    @IBAction func refreshAction(_ sender: UIButton) {
        startScan()
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        }
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished: Bool) in
            if (finished) {
                //self.view.removeFromSuperview()
                //self.removeFromParent()
            }
        }
    }
    
    func startScan() {
        scanTableViewDataSource.popUpScan.clearDiscoveredPeripherals()
        scanningActivityIndicator.isHidden = false
        scanningActivityIndicator.startAnimating()
        scanTableView.reloadData()
        scanTableViewDataSource.popUpScan.startScan()
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            self.stopScanningUI()
        }
    }
    
    func stopScanningUI() {
        DispatchQueue.main.async {
            self.scanningActivityIndicator.isHidden = true
            self.scanningActivityIndicator.stopAnimating()
            self.scanTableView.reloadData()
        }
        
    }
    
    func presentConnectionFailedAlert() {
        DispatchQueue.main.async {
            self.scanTableView.reloadData()
            let alert = UIAlertController(title: "Connection Failed", message: "Could not connect to PocketWizard. Please ensure device is turned on, in range and advertising.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default) { (okayAction) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func peripheralsDidUpdate() {
        // New peripheral found, reload table
        scanTableView.reloadData()
    }
    
    @objc private func peripheralDidConnect() {}
    /*
    @objc private func deviceReadyToAdd() {
        if index == nil {
            return
        }
        index = nil
        connecting = false
        connected = true
        scanTableView.reloadData()
        addDevice.addDevice(peripheral: deviceConnecting!)
        removeAnimate()
    }
    */
    
}
