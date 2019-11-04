//
//  SettingsViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 11/06/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard
    var colorOfCells: UIColor = .white
    
    // MARK: - IBOutlets
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var readingSpeedSlider: UISlider!
    @IBOutlet weak var readingSpeedLabel: UILabel!
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var fontSizeSlider: UISlider!
    
    // MARK: - IBActions
    
    @IBAction func siderValueChanged(_ sender: UISlider) {
        readingSpeedLabel.text = "\(Int(sender.value.rounded()))"
        defaults.set(Double(sender.value.rounded()), forKey: "Default reading speed")
    }
    
    @IBAction func fontSizeSliderValueChanged(_ sender: UISlider) {
        fontSizeLabel.text = "\(Int(sender.value.rounded()))"
        defaults.set(sender.value.rounded(), forKey: "Default font size")
    }
    
    // MARK: - Managing views
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlider()
        setupFont()
        setupSpeed()
        
        readingSpeedLabel.text = String(Int(readingSpeedSlider.value.rounded()))
        fontSizeLabel.text = String(Int(fontSizeSlider.value.rounded()))
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let version = Int(String(systemVersion)), version<13 {
            cell.backgroundColor = colorOfCells
        }
    }
    
    // MARK: - Functions
    
    func setupSlider() {
        let name = UIDevice.current.name
        
        if name.contains("iPad") {
            fontSizeSlider.minimumValue = 50.0
            fontSizeSlider.maximumValue = 200.0
        }
        else if name.contains("5S") || name.contains("SE"){
            fontSizeSlider.minimumValue = 20.0
            fontSizeSlider.maximumValue = 40.0
        }
        else {
            fontSizeSlider.minimumValue = 23.0
            fontSizeSlider.maximumValue = 70.0
        }
    }
    
    func setupFont(){
        if let fontSize = defaults.value(forKey: "Default font size") as? CGFloat {
            fontSizeSlider.setValue(Float(fontSize), animated: false)
        }
        else {
            defaults.set(CGFloat(fontSizeSlider.minimumValue), forKey: "Default font size")
            fontSizeSlider.setValue(fontSizeSlider.minimumValue, animated: false)
        }
    }
    
    func setupSpeed(){
        if let speed = defaults.value(forKey: "Default reading speed") as? Double {
            readingSpeedSlider.setValue(Float(speed), animated: false)
        }
        else {
            defaults.set(60.0, forKey: "Default reading speed")
            readingSpeedSlider.setValue(60.0, animated: false)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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

// MARK: - Dark mode

extension SettingsViewController: DarkModeApplicable {
    func toggleLightMode() {
        if let version = Int(String(systemVersion)), version<13 {
            view.backgroundColor = .white
            tableView.backgroundColor = .white
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = systemButtonColor
            tabBarController?.tabBar.barTintColor = .white
            tabBarController?.tabBar.tintColor = systemButtonColor
            colorOfCells = .white
            fontSizeLabel.textColor = .black
            readingSpeedLabel.textColor = .black
            for label in labels {
                label.textColor = .black
            }
            tableView.reloadData()
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
        }
    }
    
    func toggleDarkMode() {
        if let version = Int(String(systemVersion)), version<13 {
            let tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            view.backgroundColor = .black
            tableView.backgroundColor = .black
            navigationController?.navigationBar.barTintColor = .black
            navigationController?.navigationBar.tintColor = tintColor
            tabBarController?.tabBar.barTintColor = .black
            tabBarController?.tabBar.tintColor = tintColor
            colorOfCells = .black
            fontSizeLabel.textColor = .white
            readingSpeedLabel.textColor = .white
            for label in labels {
                label.textColor = .white
            }
            tableView.reloadData()
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        }
    }
}
