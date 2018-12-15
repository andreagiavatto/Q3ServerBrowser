//
//  ServersTableViewCell.swift
//  Q3ServerBrowser-iOS
//
//  Created by HLR on 18/11/2018.
//

import UIKit

class ServersTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ServersTableViewCellIdentifier"

    @IBOutlet private weak var gametypeLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var hostnameLabel: UILabel!
    @IBOutlet private weak var pingLabel: UILabel!

    var gametype: String? {
        didSet {
            gametypeLabel.text = gametype
        }
    }

    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }

    var hostname: String? {
        didSet {
            hostnameLabel.text = hostname
        }
    }

    var ping: NSAttributedString? {
        didSet {
            pingLabel.attributedText = ping
        }
    }
}
