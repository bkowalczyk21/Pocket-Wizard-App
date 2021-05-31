//
//  FirmwareUpdatesViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 6/25/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit



class FirmwareUpdatesViewController: UIViewController {

    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var currentVersionLabel: UILabel!
    @IBOutlet weak var updateVersionLabel: UILabel!
    @IBOutlet weak var userMessageLabel: UILabel!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pocketWizardTitle: UILabel!
    @IBOutlet weak var currentVersionTitle: UILabel!
    @IBOutlet weak var updateVersionTitle: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var currentVersionView: UIView!
    @IBOutlet weak var updatedVersionView: UIView!
    @IBOutlet weak var percentageLabel: UILabel!
    
    let shapeLayer = CAShapeLayer()
    let shapeLayer2 = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    
    private var installingUI: InstallingUI?
    private var animationTimer: Timer?
    
    var firmwareUpdateManager: FirmwareUpdateManager!
    
    enum InstallingUI : String {
        case installing1 = "Installing."
        case installing2 = "Installing.."
        case installing3 = "Installing..."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: pocketWizardLogo)
        logoContainer.addSubview(logoView)
        self.navigationItem.titleView = logoContainer
        
        nameView.layer.cornerRadius = 20
        currentVersionView.layer.cornerRadius = 20
        updatedVersionView.layer.cornerRadius = 20
        
        nameView.layer.shadowColor = UIColor.black.cgColor
        currentVersionView.layer.shadowColor = UIColor.black.cgColor
        updatedVersionView.layer.shadowColor = UIColor.black.cgColor
        updateButton.layer.shadowColor = UIColor.black.cgColor
        
        nameView.layer.shadowOffset = CGSize(width: 0, height: 3)
        currentVersionView.layer.shadowOffset = CGSize(width: 0, height: 3)
        updatedVersionView.layer.shadowOffset = CGSize(width: 0, height: 3)
        updateButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        nameView.layer.shadowRadius = 3
        currentVersionView.layer.shadowRadius = 3
        updatedVersionView.layer.shadowRadius = 3
        updateButton.layer.shadowRadius = 3
        
        nameView.layer.shadowOpacity = 0.3
        currentVersionView.layer.shadowOpacity = 0.3
        updatedVersionView.layer.shadowOpacity = 0.3
        updateButton.layer.shadowOpacity = 0.3
        
        titleLabel.font = UIFont(name: "Arial-BoldMT", size: 22)
        pocketWizardTitle.font = UIFont(name: "Arial-BoldMT", size: 20)
        currentVersionTitle.font = UIFont(name: "Arial-BoldMT", size: 20)
        updateVersionTitle.font = UIFont(name: "Arial-BoldMT", size: 20)
        productLabel.font = UIFont(name: "Arial-BoldMT", size: 20)
        currentVersionLabel.font = UIFont(name: "Arial-BoldMT", size: 20)
        updateVersionLabel.font = UIFont(name: "Arial-BoldMT", size: 20)
        percentageLabel.font = UIFont(name: "Arial-BoldMT", size: 80)
        
        percentageLabel.isHidden = true
        
        if let pwName = firmwareUpdateManager.getName() {
            productLabel.text = pwName
        }
        
        if let currentVersionString = firmwareUpdateManager.getCurrentFirmwareVersion() {
            currentVersionLabel.text = currentVersionString
        }
        
        if let updateVersionString = firmwareUpdateManager.getFirmwareUpdateVersion() {
            updateVersionLabel.text = updateVersionString
        }
        
        userMessageLabel.text = "A firmware update is available for this PocketWizard."
        
        updateButton.backgroundColor = .systemGreen
        updateButton.layer.cornerRadius = 20
        updateButton.setTitleColor(.clear, for: .disabled)
        updateButton.setTitleColor(.white, for: .normal)
        updateButton.setAttributedTitle(NSAttributedString(string: "Update", attributes: [.font : UIFont(name: "Arial-BoldMT", size: 20), .foregroundColor : UIColor.white]), for: .normal)
        updateButton.setAttributedTitle(NSAttributedString(string: "Update", attributes: [.font : UIFont(name: "Arial-BoldMT", size: 20), .foregroundColor : UIColor.clear]), for: .disabled)
        updateButton.isEnabled = true

        
    }
    
    @IBAction func beginUpdateAction(_ sender: UIButton) {
        startUpdate()
    }
    
    func startUpdate() {
        navigationItem.setHidesBackButton(true, animated: true)
        updateButton.isEnabled = false
        updateButton.backgroundColor = .clear
        userMessageLabel.text = "Downloading firmware..."
        //firmwareUpdateManager.initateFirmwareUpdate(delegate: self)
    }

}
/*
extension FirmwareUpdatesViewController: FirmwareUpdateDelegate {
    
    func didCompleteUpload() {
        userMessageLabel.text = "Upload completed. Installing update in your PocketWizard. This should take about 30 seconds."
        installingUI = .installing1
        percentageLabel.text = installingUI?.rawValue
        percentageLabel.font = UIFont(name: "Arial-BoldMT", size: 36)
        var strokeStart: CGFloat = 0
        var strokeEnd: CGFloat = 0.125
        var stroke2Start: CGFloat = 0.5
        var stroke2End: CGFloat = 0.625
        
        shapeLayer.strokeStart = strokeStart
        shapeLayer.strokeEnd = strokeEnd
        shapeLayer2.strokeStart = stroke2Start
        shapeLayer2.strokeEnd = stroke2End
        guard animationTimer == nil else {return}
        var even = true
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
            if even {
                strokeEnd += 0.125
                strokeStart += 0.125
                stroke2Start += 0.125
                stroke2End += 0.125
                if strokeStart == 1 && strokeEnd == 1.125 {
                    strokeStart = 0
                    strokeEnd = 0.125
                } else if stroke2Start == 1 && stroke2End == 1.125 {
                    stroke2Start = 0
                    stroke2End = 0.125
                }
                self.shapeLayer.strokeStart = strokeStart
                self.shapeLayer.strokeEnd = strokeEnd
                self.shapeLayer2.strokeStart = stroke2Start
                self.shapeLayer2.strokeEnd = stroke2End
                even = false
            } else {
                even = true
            }
            switch self.installingUI {
            case .installing1:
                self.installingUI = .installing2
            case .installing2:
                self.installingUI = .installing3
            case .installing3:
                self.installingUI = .installing1
            case .none:
                self.installingUI = .installing1
            }
            self.percentageLabel.text = self.installingUI?.rawValue
            
        })
    }
    
    func didCompleteInstallation() {
        userMessageLabel.text = "Update completed successfully."
        navigationItem.setHidesBackButton(false, animated: false)
        if let updateVersionString = firmwareUpdateManager.getCurrentFirmwareVersion() {
            currentVersionLabel.text = updateVersionString
        }
        percentageLabel.isHidden = true
        updatedVersionView.isHidden = true
        shapeLayer.isHidden = true
        shapeLayer2.isHidden = true
        trackLayer.isHidden = true
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    func didDownloadFirmwareImage() {
        userMessageLabel.text = "Firmware downloaded successfully. Initiating update..."
    }
    
    func didInitiateUpdate() {
        userMessageLabel.text = "Firmware upload in progress. Please stand within five feet of your PocketWizard while the update proceeds."
    
        percentageLabel.text = "0%"
        percentageLabel.isHidden = false
        
        let centerPoint = CGPoint(x: animationView.frame.size.width / 2, y: animationView.frame.size.height / 2)
        let circularPath = UIBezierPath(arcCenter: centerPoint, radius: 120, startAngle: -(CGFloat.pi / 2) , endAngle: (2 * CGFloat.pi) - (CGFloat.pi / 2), clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        animationView.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0
        animationView.layer.addSublayer(shapeLayer)
        
        shapeLayer2.path = circularPath.cgPath
        shapeLayer2.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer2.lineWidth = 10
        shapeLayer2.fillColor = UIColor.clear.cgColor
        shapeLayer2.lineCap = .round
        shapeLayer2.strokeEnd = 0
        animationView.layer.addSublayer(shapeLayer2)
    }
    
    func didUpdateFileLocation(percentageDouble: Double) {
        print(percentageDouble)
        let percentage = percentageDouble * 100
        let roundedPercentage = Int(percentage.rounded())
        percentageLabel.text = String(roundedPercentage) + "%"
        shapeLayer.strokeEnd = CGFloat(percentageDouble)
    }

    
    func firmwareUpdateFailed(error: String) {
        let alert = UIAlertController(title: "Update Failed", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true) {
            self.updateButton.isEnabled = true
            self.updateButton.backgroundColor = .systemGreen
            self.shapeLayer.isHidden = true
            self.shapeLayer2.isHidden = true
            self.trackLayer.isHidden = true
            self.percentageLabel.isHidden = true
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
    }
    
}
*/
