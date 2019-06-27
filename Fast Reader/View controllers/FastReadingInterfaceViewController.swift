//
//  FastRedaingInterfaceViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 31/12/2018.
//  Copyright © 2018 Илья Канищев. All rights reserved.
//

import UIKit

class FastReadingInterfaceViewController: UIViewController {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var wpmCounter: UILabel!
    @IBOutlet weak var wordPart1: UILabel!
    @IBOutlet weak var wordPart2: UILabel!
    @IBOutlet weak var wordPart3: UILabel!
    @IBOutlet weak var toolBarConstraint: NSLayoutConstraint!
    
    
    var book: Book?
    var timer: Timer?
    var isReading = true
    var readingSpeed = 60.0
    let defaults = UserDefaults.standard
    
    
    @IBAction func playButtonTouched(_ sender: Any) {
        changeReadingState()
    }
    
    @IBAction func decreaseReadingSpeed(_ sender: UIBarButtonItem) {
        readingSpeed = max(0, readingSpeed-10)
        wpmCounter.text = String(readingSpeed)
        if readingSpeed == 0
        {
            changeReadingState()
        }
        if isReading
        {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0/(readingSpeed/60.0), target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            timer?.fire()
        }
    }
    
    @IBAction func increaseReadingSpeed(_ sender: UIBarButtonItem) {
        readingSpeed+=10
        wpmCounter.text = String(readingSpeed)
        if isReading
        {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0/(readingSpeed/60.0), target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            timer?.fire()
        }
    }
    
    func changeReadingState() {
        if isReading
        {
            isReading = false
            timer?.invalidate()
            var items = toolbar.items
            items![3] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(FastReadingInterfaceViewController.playButtonTouched(_:)))
            toolbar.setItems(items, animated: true)
            toolBarConstraint.constant = navigationController?.navigationBar.bounds.height ?? 0
            navigationController?.navigationBar.isHidden = false
            tabBarController?.tabBar.isHidden = false
        }
        else
        {
            isReading = true
            timer = Timer.scheduledTimer(timeInterval: 1.0/(readingSpeed/60.0), target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            var items = toolbar.items
            items![3] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(FastReadingInterfaceViewController.playButtonTouched(_:)))
            toolbar.setItems(items, animated: true)
            navigationController?.navigationBar.isHidden = true
            tabBarController?.tabBar.isHidden = true
            toolBarConstraint.constant = 0
            timer?.fire()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        
        if let defaultReadingSpeed = defaults.value(forKey: "Default reading speed") as? Double {
            
            timer = Timer.scheduledTimer(timeInterval: 1.0/(defaultReadingSpeed/60.0), target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            wpmCounter.text = String(defaultReadingSpeed)
            timer?.fire()
            readingSpeed = defaultReadingSpeed
            
        }
        else {
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            wpmCounter.text = String(readingSpeed)
            timer?.fire()
            
        }
    }
    
    @objc func toggleLightMode() {
        view.backgroundColor = .white
        wpmCounter.textColor = .black
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .blue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
        tabBarController?.tabBar.barTintColor = .white
        tabBarController?.tabBar.tintColor = .blue
        toolbar.barTintColor = .white
    }
    
    @objc func toggleDarkMode() {
        view.backgroundColor = .black
        wpmCounter.textColor = .white
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        tabBarController?.tabBar.barTintColor = .black
        tabBarController?.tabBar.tintColor = .white
        toolbar.barTintColor = .black
    }
    
    
    @objc func fireTimer()
    {
        //TODO: slow down when full stop
        guard let book = book else {
            print("Error. No text found")
            return
        }
        
        if book.position >= book.text.count
        {
            timer?.invalidate()
            toolbar.isHidden = true
            wpmCounter.text = "Конец текста"
            navigationController?.navigationBar.isHidden = false
            tabBarController?.tabBar.isHidden = false
        }
        else
        {
            let parts = book.getAttributedWord()
            wordPart1.attributedText = parts[0]
            wordPart2.attributedText = parts[1]
            wordPart3.attributedText = parts[2]
        }
        
    }
}
