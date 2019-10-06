//
//  AddingTableViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 26/08/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class AddingTableViewController: UITableViewController {
    
    var colorOfCells = UIColor.white
    
    @IBOutlet var cellLabels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        if let theme = UserDefaults.standard.string(forKey: "Theme"), theme == "Dark" {
                NotificationCenter.default.post(Notification(name: .darkModeEnabled))
        }
        else {
            NotificationCenter.default.post(Notification(name: .darkModeDisabled))
        }*/
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    /*override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if colorOfCells == .white {
            cellLabels[indexPath.row].textColor = .black
        }
        else {
            let tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            cellLabels[indexPath.row].textColor = tintColor
        }
        cell.backgroundColor = colorOfCells
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddingTableViewController: DarkModeApplicable {
    func toggleDarkMode() {
        colorOfCells = .black
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        tabBarController?.tabBar.barTintColor = .black
        tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        editButtonItem.tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        tableView.reloadData()
    }
    
    func toggleLightMode() {
        colorOfCells = .white
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tabBarController?.tabBar.barTintColor = .white
        tabBarController?.tabBar.tintColor = UIButton(type: .system).tintColor
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
        editButtonItem.tintColor = UIButton(type: .system).tintColor
        tableView.reloadData()
    }
}
