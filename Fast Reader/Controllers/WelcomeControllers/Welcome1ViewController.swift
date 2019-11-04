//
//  Welcome1ViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 27/10/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class Welcome1ViewController: UIViewController {
    @IBOutlet weak var demoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        demoImage.image = UIImage(named: "Welcome 1 Image")
    }
}
