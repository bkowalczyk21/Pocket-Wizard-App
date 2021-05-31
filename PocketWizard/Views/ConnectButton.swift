//
//  ConnectButton.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 8/13/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

enum ConnectionState {
    case disconnected
    case connecting
    case connected
}

class ConnectButton: UIButton {
    
    @IBOutlet weak var connectLabel: UILabel!
    
    var connectionState: ConnectionState = .disconnected {
        didSet {
            switch connectionState {
            case .connected:
                setImage(UIImage(named: "link-disconnected"), for: .normal)
                //setTitle("Disconnect", for: .normal)
                connectLabel.text = "Disconnect"
            case .connecting:
                //setTitle("Connecting...", for: .normal)
                connectLabel.text = "Connecting..."
            case .disconnected:
                setImage(UIImage(named: "link-connected"), for: .normal)
                //setTitle("Connect", for: .normal)
                connectLabel.text = "Connect"
            }
        }
    }
}
