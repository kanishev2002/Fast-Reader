//
//  Welcome2ViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 30/10/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class Welcome2ViewController: UIViewController {
    
    @IBOutlet weak var themeImageView: UIImageView!
    
    @IBAction func lightButtonWasTapped(_ sender: UIButton) {
        UserDefaults.standard.set("Light", forKey: "Theme")
        themeImageView.image = UIImage(named: "Welcome_2_image_light")
        NotificationCenter.default.post(Notification(name: .darkModeDisabled))
    }
    
    @IBAction func darkButtonWasTapped(_ sender: UIButton) {
        UserDefaults.standard.set("Light", forKey: "Theme")
        themeImageView.image = UIImage(named: "Welcome_2_image_dark")
        NotificationCenter.default.post(Notification(name: .darkModeEnabled))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeImageView.image = UIImage(named: "DemoLightImage")
    }
}
