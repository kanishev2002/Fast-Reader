//
//  FastRedaingInterfaceViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 31/12/2018.
//  Copyright © 2018 Илья Канищев. All rights reserved.
//

import UIKit

fileprivate let punctuationMarks: Set = [Character("."), Character(","), Character("?"), Character("!"), Character(";")]

class FastReadingInterfaceViewController: UIViewController {
    //MARK: - IBOutlets
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var wpmCounter: UILabel!
    @IBOutlet weak var wordPart1: UILabel!
    @IBOutlet weak var wordPart2: UILabel!
    @IBOutlet weak var wordPart3: UILabel!
    @IBOutlet weak var readAgainButton: UIButton!
    @IBOutlet weak var last15WordsButton: UIButton!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var readingSpeedStepper: UIStepper!
    
    // MARK: - Variables
    
    var savedBook: Book?
    var text: [String]?
    var position = 0
    var readingSpeed = 60.0
    var bookIsSaved = false
    
    private var timerShouldRepeat = false
    private var timer: Timer?
    private var tmpTimer: Timer?
    private var isReading = true
    private var startTime = 0.0
    private var endTime = 0.0
    private var totalTime = 0.0
    private var wordCount = 0
    
    private var currentStatEntry = DataController.shared.getStats().last ?? DataController.shared.getNewStatisticsEntry()
    private var stats = DataController.shared.getStats()
    
    private let defaults = UserDefaults.standard
    private let dataController = DataController.shared
    private let localizedWPM = NSLocalizedString(" words/min", comment: "words per minute")
    
    
    // MARK: - IBActions
    
    @IBAction func playButtonTouched(_ sender: Any) {
        //print("playButtonTouched")
        changeReadingState()
    }
    
    @IBAction func readAgainButtonTouched(_ sender: UIButton) {
        if let book = savedBook {
            book.position = 0
            dataController.saveData()
        }
        position = 0
        changeReadingState()
        sender.isHidden = true
        last15WordsButton.isHidden = true
        tabBarController?.tabBar.isHidden = true
        toolbar.isHidden = false
    }
    
    @IBAction func last15WordsButtonTouched(_ sender: UIButton) {
        if let book = savedBook {
            book.position = max(book.position - 15, 0)
            dataController.saveData()
        }
        position = max(position - 15, 0)
        changeReadingState()
        sender.isHidden = true
        readAgainButton.isHidden = true
        tabBarController?.tabBar.isHidden = true
        toolbar.isHidden = false
    }
    
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        readingSpeed = sender.value
        wpmCounter.text = String(Int(readingSpeed)) + localizedWPM
        print(1)
    }
    
    @IBAction func rewindButtonTouched(_ sender: UIBarButtonItem) {
        position = max(position - 15, 0)
        if !isReading, let text = text {
            let parts = getAttributedWord(text[position])
            position += 1
            currentStatEntry.wordsCount += 1
            wordPart1.attributedText = parts[0]
            wordPart2.attributedText = parts[1]
            wordPart3.attributedText = parts[2]
        }
        configurePercentageLabel()
    }
    
    
    @IBAction func fastForwardButtonTouched(_ sender: Any) {
        if let text = text {
            position = min(position + 15, text.count - 1)
        }
        else {
            position = 0
        }
        if !isReading, let text = text {
            let parts = getAttributedWord(text[position])
            position += 1
            currentStatEntry.wordsCount += 1
            wordPart1.attributedText = parts[0]
            wordPart2.attributedText = parts[1]
            wordPart3.attributedText = parts[2]
        }
        configurePercentageLabel()
    }
    
    // MARK: - Managing views
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        if isReading {
            changeReadingState()
        }
        currentStatEntry.averageSpeed = Double(currentStatEntry.wordsCount) / (currentStatEntry.readingTime / 60.0)
        let words = defaults.integer(forKey: "wordsCount")
        let time  = defaults.double(forKey: "totalTimeOfReading")
        defaults.set(words+wordCount, forKey: "wordsCount")
        defaults.set(time+totalTime, forKey: "totalTimeOfReading")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        totalTime = 0.0
        wordCount = 0
        tabBarController?.tabBar.isHidden = true
        configurePercentageLabel()
        if bookIsSaved {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        if let theme = defaults.string(forKey: "Theme"), theme == "Dark" {
            toggleDarkMode()
        }
        else {
            toggleLightMode()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.toolbar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(prepareForBackground), name: NSNotification.Name("applicationWillResignActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        
        tabBarController?.tabBar.isHidden = true
        readAgainButton.isHidden = true
        last15WordsButton.isHidden = true
        navigationController?.navigationBar.isHidden = true
        let saveButtonTitle = NSLocalizedString("Save", comment: "Save button title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: saveButtonTitle, style: .plain, target: self, action: #selector(saveButtonTouched))
        
        if let lastExitTime = defaults.value(forKey: "lastExitTime") as? Date, defaults.integer(forKey: "lastExitDay") != 0, defaults.integer(forKey: "lastExitWeek") != 0 {
            let secondsInAnHour = 60.0 * 60.0
            let timeDifference = (Date().timeIntervalSince(lastExitTime) / secondsInAnHour) as Double
            print("timeDifference is \(timeDifference)")
            let currentWeekday = Calendar.current.component(.weekday, from: Date())
            let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
            let lastExitDay = defaults.integer(forKey: "lastExitDay")
            let lastExitWeek = defaults.integer(forKey: "lastExitWeek")
            if currentWeekday != lastExitDay || currentWeek != lastExitWeek {
                currentStatEntry = dataController.getNewStatisticsEntry()
                print("FRIVC Added a new stat")
                stats.append(currentStatEntry)
                if stats.count > 7 {
                    dataController.deleteStatisticsEntry(stats[0])
                    stats.remove(at: 0)
                    print("FRIVC Deleted a stat")
                }
                print("Number of stats: \(stats.count)")
            }
        }
        else {
            print("Last exit not found")
        }
        
        if let defaultReadingSpeed = defaults.value(forKey: "Default reading speed") as? Double {
            timer = Timer.scheduledTimer(timeInterval: 1.0/(defaultReadingSpeed/60.0), target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            wpmCounter.text = String(defaultReadingSpeed) + localizedWPM
            readingSpeedStepper.value = defaultReadingSpeed
            timer?.tolerance = 0
            timer?.fire()
            readingSpeed = defaultReadingSpeed
            print("Reading speed: \(readingSpeed)")
        }
        else {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            wpmCounter.text = String(readingSpeed) + localizedWPM
            readingSpeedStepper.value = readingSpeed
            print("Reading speed: \(readingSpeed)")
            timer?.tolerance = 0
            timer?.fire()
        }
        startTime = Date.timeIntervalSinceReferenceDate
        percentageLabel.isHidden = true
        readingSpeedStepper.isHidden = true
    }
    
    // MARK: - Functions
    
    func changeReadingState() {
        if isReading {
            isReading = false
            timer?.invalidate()
            tmpTimer?.invalidate()
            endTime = Date().timeIntervalSinceReferenceDate
            currentStatEntry.readingTime += (endTime - startTime)
            totalTime += (endTime - startTime)
            var items = toolbar.items
            items![3] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(FastReadingInterfaceViewController.playButtonTouched(_:)))
            toolbar.setItems(items, animated: true)
            navigationController?.navigationBar.isHidden = false
            if savedBook != nil {
                savedBook!.position = Int64(self.position)
                //dataController.saveData()
            }
            percentageLabel.isHidden = false
            readingSpeedStepper.isHidden = false
            configurePercentageLabel()        }
        else {
            isReading = true
            timer = Timer.scheduledTimer(timeInterval: 1.0/(readingSpeed/60.0), target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            print("Reading speed is \(readingSpeed)")
            var items = toolbar.items
            items![3] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(FastReadingInterfaceViewController.playButtonTouched(_:)))
            toolbar.setItems(items, animated: true)
            navigationController?.navigationBar.isHidden = true
            timer?.fire()
            startTime = Date().timeIntervalSinceReferenceDate
            percentageLabel.isHidden = true
            readingSpeedStepper.isHidden = true
        }
    }
    
    func configurePercentageLabel() {
        if let text = text {
            let position = Double(self.position)
            let wordsCount = Double(text.count)
            let localizedPercentageLabel = NSLocalizedString("Read: ", comment: "percentage label")
            let percentage = "\(Int((position/wordsCount)*100.0))% "
            let remainingLabel = NSLocalizedString("Remaining: ", comment: "percentage label")
            let remaining = "\(Int((wordsCount - position) / readingSpeed)) "
            let localizedMinutes = NSLocalizedString("min", comment: "minutes")
            percentageLabel.text = localizedPercentageLabel+percentage+remainingLabel+remaining+localizedMinutes
        }
    }
    
    func getAttributedWord(_ word: String) -> [NSAttributedString] {
        
        let index = word.index(word.startIndex, offsetBy: getRedLetterPosition(word.count))
        let font: String
        
        if let defaultFont = defaults.string(forKey: "Default font"), defaults.integer(forKey: "Default font size") != 0 {
            font = defaultFont
        }
        else {
            defaults.set("Helvetica", forKey: "Default font")
            defaults.set(50, forKey: "Default font size")
            font = "Helvetica"
        }
        
        var fontSize = defaults.integer(forKey: "Default font size")
        if fontSize == 0 {
            fontSize = 30
        }
        
        let themeTextColor: UIColor
        
        if #available(iOS 13.0, *) {
            themeTextColor = .label
        } else if let theme = defaults.string(forKey: "Theme"), theme == "Dark" {
            themeTextColor = .white
        }
        else {
            themeTextColor = .black
        }
        
        
        let attributes: [NSAttributedString.Key: Any] = [.font : UIFont(name: font, size: CGFloat(fontSize))!, .foregroundColor : themeTextColor]
        
        let part1 = NSAttributedString(string: String(word[..<index]), attributes: attributes)
        let part2 = NSMutableAttributedString(string: String(word[index]), attributes: attributes)
        part2.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 1))
        
        let nextIndex = word.index(after: index)
        let part3 = NSAttributedString(string: String(word[nextIndex ..< word.endIndex]), attributes: attributes)
        
        let parts = [part1, part2, part3]
        return parts
    }
    
    func getRedLetterPosition(_ length: Int) -> Int
    {
        return ((length + 6) / 4) - 1
    }
    
    // MARK: - @Objc functions
    
    @objc func prepareForBackground() {
        if isReading {
            changeReadingState()
        }
        currentStatEntry.averageSpeed = Double(currentStatEntry.wordsCount) / (currentStatEntry.readingTime / 60.0)
        dataController.saveData()
    }
    
    
    @objc func fireTimer()
    {
        var text: [String] 
        
        if let savedText = self.text {
            text = savedText
        }
        else {
            print("Error. No text found")
            return
        }
        
        if position >= text.count {
            isReading = false
            timer?.invalidate()
            if startTime == 0.0 {
                startTime = Date().timeIntervalSinceReferenceDate
            }
            endTime = Date().timeIntervalSinceReferenceDate
            currentStatEntry.readingTime += (endTime - startTime)
            totalTime += (endTime - startTime)
            toolbar.isHidden = true
            readingSpeedStepper.isHidden = true
            navigationController?.navigationBar.isHidden = false
            let localizedEndOfText = NSLocalizedString("End of text", comment: "Localized message shown after end of text")
            wpmCounter.text = localizedEndOfText
            readAgainButton.isHidden = false
            last15WordsButton.isHidden = false
            if savedBook != nil {
                savedBook!.position = Int64(self.position)
                dataController.saveData()
            }
            wordPart1.text = ""
            wordPart2.text = ""
            wordPart3.text = ""
        }
        else {
            wpmCounter.text = String(Int(readingSpeed)) + localizedWPM
            print("Reading speed: \(readingSpeed)")
            let parts = getAttributedWord(text[position])
            if punctuationMarks.contains(parts[2].string.last ?? Character(" ")) {
                tmpTimer = Timer(fireAt: Date().addingTimeInterval(1.5*1.0/(readingSpeed/60.0)), interval: 0.0, target: self, selector: #selector(fireTmpTimer(_:)), userInfo: nil, repeats: false)
                timer?.invalidate()
                print("Timer has launched tmpTimer")
                RunLoop.current.add(tmpTimer!, forMode: .default)
                
            }
            position += 1
            currentStatEntry.wordsCount += 1
            wordCount += 1
            wordPart1.attributedText = parts[0]
            wordPart2.attributedText = parts[1]
            wordPart3.attributedText = parts[2]
        }
        
    }
    
    @objc func fireTmpTimer(_ timer: Timer) {
        print("tmpTimer fired")
        self.timer = Timer.scheduledTimer(timeInterval: 1.0 / (readingSpeed/60.0), target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        self.timer?.fire()
    }
    
    @objc func saveButtonTouched() {
        let localizedTitle = NSLocalizedString("Save as...", comment: "Alert title")
        let localizedMessage = NSLocalizedString("Input name and author of the book", comment: "Alert message")
        let alertController = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            let localizedNamePlacholder = NSLocalizedString("Name of the book", comment: "Name of book placeholder")
            textField.placeholder = localizedNamePlacholder
        }
        alertController.addTextField { (textField) in
            let localizedAuthorPlaceholder = NSLocalizedString("Author's name", comment: "Author placeholder")
            textField.placeholder = localizedAuthorPlaceholder
        }
        let localizedCancelActionTitle = NSLocalizedString("Cancel", comment: "Cancel alert action")
        let cancelAction = UIAlertAction(title: localizedCancelActionTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
            guard let name = alertController.textFields!.first!.text, let author = alertController.textFields!.last!.text, !name.isEmpty, !author.isEmpty else {
                return
            }
            
            self.dataController.saveBook(named: name, withText: self.text!.joined(separator: " "), by: author, withPosition: self.position)
        })
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: {
            NotificationCenter.default.post(Notification(name: Notification.Name("libraryShouldUpdate")))
            self.savedBook = self.dataController.lastSavedBook
        })
        bookIsSaved = true
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    
}

// MARK: - Dark mode

extension FastReadingInterfaceViewController: DarkModeApplicable {
    func toggleLightMode() {
        if let version = Int(String(systemVersion)), version<13 {
            view.backgroundColor = .white
            wpmCounter.textColor = .black
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = systemButtonColor
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
            tabBarController?.tabBar.barTintColor = .white
            tabBarController?.tabBar.tintColor = systemButtonColor
            toolbar.barTintColor = .white
        }
    }
    
    func toggleDarkMode() {
        if let version = Int(String(systemVersion)), version<13 {
            let tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            view.backgroundColor = .black
            wpmCounter.textColor = tintColor
            navigationController?.navigationBar.barTintColor = .black
            navigationController?.navigationBar.tintColor = tintColor
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
            tabBarController?.tabBar.barTintColor = .black
            tabBarController?.tabBar.tintColor = tintColor
            toolbar.barTintColor = .black
            toolbar.tintColor = tintColor
        }
    }
}
