//
//  iTunesImportViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 18/09/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class iTunesImportViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        if let theme = UserDefaults.standard.string(forKey: "Theme"), theme == "Dark" {
            toggleDarkMode()
        }
        else {
            toggleLightMode()
        }
    }
}

extension iTunesImportViewController: DarkModeApplicable {
    func toggleDarkMode() {
        if let version = Int(String(systemVersion)), version<13 {
            view.backgroundColor = .black
            textView.backgroundColor = .black
            textView.textColor = .white
            tabBarController?.tabBar.barTintColor = .black
            tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            navigationController?.navigationBar.barTintColor = .black
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        }
    }
    
    func toggleLightMode() {
        if let version = Int(String(systemVersion)), version<13 {
            view.backgroundColor = .white
            textView.backgroundColor = .white
            textView.textColor = .black
            tabBarController?.tabBar.barTintColor = .white
            tabBarController?.tabBar.tintColor = systemButtonColor
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
            navigationController?.navigationBar.tintColor = systemButtonColor
        }
    }
    
    
}
