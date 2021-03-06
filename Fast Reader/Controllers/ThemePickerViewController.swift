//
//  themePickerViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 14/06/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit
import Foundation

let systemVersion = UIDevice.current.systemVersion.split(separator: ".")[0]

class ThemePickerViewController: UITableViewController {
    
    // MARK: - Managing views
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - TableView datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let defaults = UserDefaults.standard
        if let version = Int(String(systemVersion)), version<13 {
            if indexPath.item == 0 {
                defaults.set("Light", forKey: "Theme")
                NotificationCenter.default.post(Notification(name: .darkModeDisabled))
            }
            else {
                defaults.set("Dark", forKey: "Theme")
                NotificationCenter.default.post(Notification(name: .darkModeEnabled))
            }
        }
        else {
            print("Unable to read system version")
        }
    }
}


extension Notification.Name {
    static let darkModeEnabled = Notification.Name("com.hselyceum.Fast-Reader.darkModeEnabled")
    static let darkModeDisabled = Notification.Name("com.hselyceum.Fast-Reader.darkModeDisabled")
}
