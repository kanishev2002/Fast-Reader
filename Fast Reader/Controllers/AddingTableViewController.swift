//
//  AddingTableViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 26/08/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

public let systemButtonColor = UIButton(type: .system).tintColor

class AddingTableViewController: UITableViewController {
    
    var colorOfCells = UIColor.white
    
    @IBOutlet var cellLabels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        //defaults.set(false, forKey: "First launch")
        if defaults.bool(forKey: "First launch") == false{
            self.performSegue(withIdentifier: "ShowingWelcomeScreen", sender: self)
            defaults.set(true, forKey: "First launch")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        if let theme = UserDefaults.standard.string(forKey: "Theme"), theme == "Dark" {
            NotificationCenter.default.post(Notification(name: .darkModeEnabled))
        }
        else {
            NotificationCenter.default.post(Notification(name: .darkModeDisabled))
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let version = Int(String(systemVersion)), version<13 {
            cell.backgroundColor = colorOfCells
            cellLabels[indexPath.row].textColor = colorOfCells == .white ? .black : .white
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "ShowingWelcomeScreen"{
            if segue.destination is WelcomePageViewController {
                print("Segue went well")
            }
        }
        else{
            print("Something is wrong with segue")
        }
    }
    
}

// MARK: - Dark mode

extension AddingTableViewController: DarkModeApplicable {
    func toggleDarkMode() {
        if let version = Int(String(systemVersion)), version<13 {
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
    }
    
    func toggleLightMode() {
        if let version = Int(String(systemVersion)), version<13 {
            colorOfCells = .white
            view.backgroundColor = .white
            tableView.backgroundColor = .white
            tabBarController?.tabBar.barTintColor = .white
            tabBarController?.tabBar.tintColor = systemButtonColor
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
            editButtonItem.tintColor = systemButtonColor
            tableView.reloadData()
        }
    }
}
