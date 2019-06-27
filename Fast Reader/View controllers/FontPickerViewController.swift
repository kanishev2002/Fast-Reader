//
//  FontPickerViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 14/06/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class FontPickerViewController: UITableViewController {
    
    var fontNames: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60.0
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fonts = fontNames{
            return fonts.count
        }
        print("FontPickerViewController didn't get fonts")
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontPickerCell", for: indexPath) as! FontPickerCell
        cell.currentFont = fontNames![indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let defaults = UserDefaults.standard
        if let fonts = fontNames{
            defaults.set(fonts[indexPath.item], forKey: "Default font")
        }
        else
        {
            print("Unable to unwrap fontNames")
            defaults.set("Helvetica", forKey: "Default font")
        }
        print(defaults.string(forKey: "Default font")!)
    }

    

}
