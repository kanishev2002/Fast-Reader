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
    @IBOutlet weak var DisplayedWord: UILabel!
    var textToRead: [String]? = nil
    var book: Book?
    var currentIndex = 0
    var timer: Timer?
    var isReading = true
    var readingSpeed = 60.0 // TODO: integration with settings
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
        }
        else
        {
            isReading = true
            timer = Timer.scheduledTimer(timeInterval: 1.0/(readingSpeed/60.0), target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            var items = toolbar.items
            items![3] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(FastReadingInterfaceViewController.playButtonTouched(_:)))
            toolbar.setItems(items, animated: true)
            timer?.fire()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DisplayedWord.text=String(textToRead?.first ?? "Nothing here yet...")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        timer?.fire()
        wpmCounter.text = String(readingSpeed)
    }
    @objc func fireTimer()
    {
        
        guard let textToRead = textToRead else {
            print("Error. No text found")
            return
        }
        DisplayedWord.text = textToRead[currentIndex]
        currentIndex+=1
        if currentIndex >= textToRead.count
        {
            timer?.invalidate()
            toolbar.isHidden = true
            wpmCounter.text = "Конец текста"
        }
    }
}
