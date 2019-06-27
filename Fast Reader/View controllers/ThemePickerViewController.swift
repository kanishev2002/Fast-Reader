//
//  themePickerViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 14/06/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit
import Foundation

class ThemePickerViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let defaults = UserDefaults.standard
        if indexPath.item == 0 {
            defaults.set("Light", forKey: "Theme")
            NotificationCenter.default.post(Notification(name: .darkModeDisabled))
        }
        else {
            defaults.set("Dark", forKey: "Theme")
            NotificationCenter.default.post(Notification(name: .darkModeEnabled))
        }
    }
}


extension Notification.Name {
    static let darkModeEnabled = Notification.Name("com.hselyceum.Fast-Reader.darkModeEnabled")
    static let darkModeDisabled = Notification.Name("com.hselyceum.Fast-Reader.darkModeDisabled")
}
