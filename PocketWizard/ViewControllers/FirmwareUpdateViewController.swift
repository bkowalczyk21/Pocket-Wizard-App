//
//  FirmwareUpdateViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 11/11/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//


import UIKit
import CoreBluetooth

class FirmwareUpdateViewController: UIViewController {

    @IBOutlet weak var nameView: RoundedShadowView!
    @IBOutlet weak var currentVersionView: RoundedShadowView!
    @IBOutlet weak var updatedVersionView: RoundedShadowView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pocketWizardTitle: UILabel!
    @IBOutlet weak var currentVersionTitle: UILabel!
    @IBOutlet weak var updatedVersionTitle: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var currentVersionLabel: UILabel!
    @IBOutlet weak var updatedVersionLabel: UILabel!
    @IBOutlet weak var userMessageLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var updateButton: FirmwareUpdateButton!
    @IBOutlet weak var updateProgressView: UpdateProgressAnimationView!
    
    private var installingText: InstallingText = .one
    private var timer: Timer?
    
    var selectedNR1: CBPeripheral!
    
    enum InstallingText: String {
        case one = "Intalling."
        case two = "Installing.."
        case three = "Installing..."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = PWLogoView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        titleLabel.font = .arial22
        pocketWizardTitle.font = .arial20
        currentVersionTitle.font = .arial20
        updatedVersionTitle.font = .arial20
        productLabel.font = .arial20
        currentVersionLabel.font = .arial20
        updatedVersionLabel.font = .arial20
        percentageLabel.font = .arial80
        percentageLabel.isHidden = true
        updateButton.isEnabled = true
        userMessageLabel.text = "A firmware update is available for this PocketWizard."
        
        //TODO: Once firmware manager is complete
        updatedVersionLabel.text = FirmwareManager.instance.latestAvailableFirmwareUpdate?.version
        
        if let nr1Data = CoreDataManager.instance.getNR1WithUUID(uuid: selectedNR1.identifier, context: CoreDataManager.instance.persistentContainer.viewContext),
           let modelNumber = nr1Data.modelNumber,
           let currentFirmwareVersion = nr1Data.firmwareRevision {
            productLabel.text = modelNumber
            currentVersionLabel.text = currentFirmwareVersion
            
        }
    }
    
    @IBAction func updateButtonAction(_ sender: UIButton) {
        updateButton.isEnabled = false
        navigationItem.setHidesBackButton(true, animated: true)
        userMessageLabel.text = "Downloading new firmware..."
        FirmwareManager.instance.fetchFirmwareImage(delegate: self)
    }
    

    func didActionAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

extension FirmwareUpdateViewController: FirmwareDownloadDelegate {
    
    func didDownloadFirmware() {
        DispatchQueue.main.async {
            self.userMessageLabel.text = "Firmware downloaded successfully. Initiating update..."
        }
        
        BluetoothManager.instance.initiateFirmwareUpdateFor(nr1: selectedNR1, delegate: self)
    }
    
    func failedToDownloadFirmware(userMessage: String) {
        didActionAlert(title: "Firmware Download Failed", message: userMessage)
        updateButton.isEnabled = true
        navigationItem.setHidesBackButton(false, animated: false)
        userMessageLabel.text = "Something went wrong. Please try update again."
    }
    
}

extension FirmwareUpdateViewController: FirmwareUpdateDelegate {
    
    func didInitiateUpdate() {
        userMessageLabel.text = "Firmware upload in progress. Please stand within five feet of your PocketWizard while the update proceeds."
        percentageLabel.text = "0%"
        percentageLabel.isHidden = false
        updateProgressView.addLayersToView()
    }
    
    func didUpdateFileLocation(percentageDouble: Double) {
        updateProgressView.shapeLayer.strokeEnd = CGFloat(percentageDouble)
        let percentage = percentageDouble * 100
        let roundedPercentage = Int(percentage.rounded())
        percentageLabel.text = String(roundedPercentage) + "%"
    }
    
    func didCompleteUpload() {
        userMessageLabel.text = "Upload completed. Installing update in your PocketWizard. This should take about 30 seconds."
        installingText = .one
        percentageLabel.text = installingText.rawValue
        percentageLabel.font = UIFont(name: "Arial-BoldMT", size: 36)
        updateProgressView.setUpLayersForInstallingAnimation()
        guard timer == nil else {return}
        var even = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [self] (timer) in
            if even {
                updateProgressView.installingAnimationTick()
                even = false
            } else {
                even = true
            }
            switch installingText {
            case .one:
                installingText = .two
            case .two:
                installingText = .three
            case .three:
                installingText = .one
            }
            percentageLabel.text = installingText.rawValue
        })
    }
    
    func didCompleteInstallation(updatedFirmwareRevision: String) {
        userMessageLabel.text = "Update completed successfully."
        navigationItem.setHidesBackButton(false, animated: false)
        currentVersionLabel.text = updatedFirmwareRevision
        percentageLabel.isHidden = true
        updatedVersionView.isHidden = true
        updateProgressView.removeLayers()
        timer?.invalidate()
        timer = nil
    }
    
    func firmwareUpdateFailed(error: String) {
        didActionAlert(title: "Firmware Update Failed", message: error)
        userMessageLabel.text = "Something went wrong. Please try update again."
        percentageLabel.isHidden = true
        updateProgressView.removeLayers()
        updateButton.isEnabled = true
        navigationItem.setHidesBackButton(false, animated: true)
    }
    
    
}
