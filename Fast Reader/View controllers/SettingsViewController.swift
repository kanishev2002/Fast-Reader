//
//  SettingsViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 11/06/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    var colorOfCells: UIColor = .white
    
    
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var readingSpeedSlider: UISlider!
    
    @IBOutlet weak var readingSpeedLabel: UILabel!
    
    @IBAction func siderValueChanged(_ sender: UISlider) {
        readingSpeedLabel.text = "\(Int(sender.value.rounded()))"
        defaults.set(Double(sender.value.rounded()), forKey: "Default reading speed")
    }
    
    
    @IBOutlet weak var fontSizeLabel: UILabel!
    
    @IBAction func fontSizeSliderValueChanged(_ sender: UISlider) {
        fontSizeLabel.text = "\(Int(sender.value.rounded()))"
        defaults.set(sender.value.rounded(), forKey: "Default font size")
    }
    
    @IBOutlet weak var fontSizeSlider: UISlider!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
        let name = UIDevice.current.name
        
        
        if name.split(separator: " ")[0] == "iPad" {
            fontSizeSlider.minimumValue = 50.0
            fontSizeSlider.maximumValue = 200.0
        }
        else if name.split(separator: " ").last == "SE" || name.split(separator: " ").last == "5S"{
            fontSizeSlider.minimumValue = 20.0
            fontSizeSlider.maximumValue = 40.0
        }
        else {
            fontSizeSlider.minimumValue = 30.0
            fontSizeSlider.maximumValue = 70.0
        }
        
        
        if let fontSize = defaults.value(forKey: "Default font size") as? CGFloat {
            fontSizeSlider.setValue(Float(fontSize), animated: false)
        }
        else {
            defaults.set(CGFloat(fontSizeSlider.minimumValue), forKey: "Default font size")
            fontSizeSlider.setValue(fontSizeSlider.minimumValue, animated: false)
        }
        
        
        if let speed = defaults.value(forKey: "Default reading speed") as? Double {
            readingSpeedSlider.setValue(Float(speed), animated: false)
        }
        else {
            defaults.set(60.0, forKey: "Default reading speed")
            readingSpeedSlider.setValue(60.0, animated: false)
        }
        
        
        readingSpeedLabel.text = String(Int(readingSpeedSlider.value.rounded()))
        fontSizeLabel.text = String(Int(fontSizeSlider.value.rounded()))
    }
    
    @objc func toggleLightMode() {
        tableView.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        tabBarController?.tabBar.barTintColor = .white
        tabBarController?.tabBar.tintColor = .blue
        colorOfCells = .white
        fontSizeLabel.textColor = .black
        readingSpeedLabel.textColor = .black
        for label in labels {
            label.textColor = .black
        }
        tableView.reloadData()
    }
    
    @objc func toggleDarkMode() {
        tableView.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        tabBarController?.tabBar.barTintColor = .black
        tabBarController?.tabBar.tintColor = .white
        colorOfCells = .black
        fontSizeLabel.textColor = .white
        readingSpeedLabel.textColor = .white
        for label in labels {
            label.textColor = .white
        }
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = colorOfCells
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier{
            switch identifier {
            case "fontPickerSegue":
                var fonts: [String] = []
                for family in UIFont.familyNames{
                    fonts.append(contentsOf: UIFont.fontNames(forFamilyName: family))
                }
                fonts.sort()
                if let destination = segue.destination as? FontPickerViewController{
                    destination.fontNames = fonts
                }
                break
            default: break
            }
        }
    }

}
