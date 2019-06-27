//
//  FontPickerCell.swift
//  Fast Reader
//
//  Created by Илья Канищев on 14/06/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class FontPickerCell: UITableViewCell {
    var attributes: [NSAttributedString.Key : Any] = [:]
    var currentFont: String? {
        didSet{
            fontLabel.isUserInteractionEnabled = false
            if let name = currentFont {
                attributes[.font] = UIFont(name: name, size: 21.0)
                let attributedText = NSAttributedString(string: name, attributes: attributes)
                fontLabel.attributedText = attributedText
            }
            else {
                print("couldn't set font in FontPickerCell")
            }
        }
    }
    @IBOutlet weak var fontLabel: UILabel!
    override func prepareForReuse() {
        fontLabel.attributedText = NSAttributedString(string: "")
    }
    
}
