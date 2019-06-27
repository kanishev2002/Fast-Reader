//
//  LibraryCell.swift
//  Fast Reader
//
//  Created by Илья Канищев on 25/06/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class LibraryCell: UITableViewCell {

    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.bookImage.image = nil
        self.nameLabel.text = nil
        self.authorLabel.text = nil
    }

}
