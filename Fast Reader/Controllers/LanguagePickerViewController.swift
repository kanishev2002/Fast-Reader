//
//  LanguagePickerViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 11/08/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class LanguagePickerViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}

extension LanguagePickerViewController: DarkModeApplicable{
    func toggleDarkMode() {
        // TODO: implement
    }
    
    func toggleLightMode() {
        // TODO: implement
    }
    
    
}

