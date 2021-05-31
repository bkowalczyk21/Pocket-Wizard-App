//
//  StoreViewController.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/26/19.
//  Copyright © 2019 Bryce Kowalczyk. All rights reserved.
//

import UIKit
import WebKit

class StoreViewController: UIViewController, WKNavigationDelegate {

    // Storyboard Outlets
    @IBOutlet weak var storeWebView: WKWebView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
 
    // PW URL String literal
    let pocketWizardUrl = "https://www.pocketwizard.com"
    
    override func viewDidLoad() {
        // Load the view
        super.viewDidLoad()

        // Assign VC as Web Kit Web View Navigation Delegate
        storeWebView.navigationDelegate = self
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Add PW logo to nav bar title view
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: pocketWizardLogo)
        logoContainer.addSubview(logoView)
        self.navigationItem.titleView = logoContainer
        
        // "Loading..." UI scheme
        loadingView.layer.cornerRadius = 15
        loadingLabel.font = .systemFont(ofSize: 20, weight: .medium)
        loadingLabel.textColor = .gray
        
        // Start the actvity indicator
        activityIndicator.startAnimating()
        
        // Load PocketWizard.com homepage in WKWebView
        if let url = URL(string: pocketWizardUrl) {
            let urlRequest = URLRequest(url: url)
            self.storeWebView.load(urlRequest)
        }
    
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Page loaded, clear "loading..." UI
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
    }

}

