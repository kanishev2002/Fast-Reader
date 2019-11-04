//
//  BarChartViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 11/08/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit
import Charts

// MARK: - Weekdays
fileprivate let Monday = NSLocalizedString("Mon", comment: "Monday")
fileprivate let Tuesday = NSLocalizedString("Tue", comment: "Tuesday")
fileprivate let Wednesday = NSLocalizedString("Wed", comment: "Wednesday")
fileprivate let Thursday = NSLocalizedString("Thu", comment: "Thursday")
fileprivate let Friday = NSLocalizedString("Fri", comment: "Friday")
fileprivate let Saturday = NSLocalizedString("Sat", comment: "Saturday")
fileprivate let Sunday = NSLocalizedString("Sun", comment: "Sunday")

fileprivate let weekdays = [
    -6 : Saturday,
    -5 : Monday,
    -4 : Tuesday,
    -3 : Wednesday,
    -2 : Thursday,
    -1 : Friday,
    0 : Saturday,
    1 : Sunday,
    2 : Monday,
    3 : Tuesday,
    4 : Wednesday,
    5 : Thursday,
    6 : Friday,
    7 : Saturday
]

fileprivate let colors: [String : UIColor] = [
    Monday : .red,
    Tuesday : .orange,
    Wednesday : .yellow,
    Thursday : .green,
    Friday : .systemBlue,
    Saturday : .blue,
    Sunday : .purple
]

class MyProfileViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var readTodayLabel: UILabel!
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var timeOfReadingLabel: UILabel!
    @IBOutlet weak var maxReadingSpeedLabel: UILabel!
    @IBOutlet weak var timeEconomyLabel: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    
    // MARK: - Variables
    var stats = DataController.shared.getStats()
    var viewControllerWasLoaded = false
    let defaults = UserDefaults.standard
    
    // MARK: - Managing views
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewControllerWasLoaded {
            setupBarChart()
            setupLabels()
        }
        viewControllerWasLoaded = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
        barChart.noDataText = NSLocalizedString("Not enough information yet", comment: "Empty chart message")
        barChart.noDataFont = .systemFont(ofSize: 25.0)
        barChart.noDataTextColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        if let theme = defaults.string(forKey: "Theme"), theme == "Dark"{
            toggleDarkMode()
        }
        else {
            toggleLightMode()
        }
        print("Last exit day: \(defaults.integer(forKey: "lastExitDay"))")
        print("Last exit week: \(defaults.integer(forKey: "lastExitWeek"))")
        print("Current day: \(Calendar.current.component(.weekday, from: Date()))")
        print("Current week: \(Calendar.current.component(.weekOfYear, from: Date()))")
        if defaults.integer(forKey: "lastExitDay") != 0, defaults.integer(forKey: "lastExitWeek") != 0 {
            let currentWeekday = Calendar.current.component(.weekday, from: Date())
            let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
            let lastExitDay = defaults.integer(forKey: "lastExitDay")
            let lastExitWeek = defaults.integer(forKey: "lastExitWeek")
            if (currentWeekday - lastExitDay == 1 || currentWeekday - lastExitDay == -6) && currentWeek == lastExitWeek {
                stats.append(DataController.shared.getNewStatisticsEntry())
            }
            else if lastExitWeek != currentWeek {
                DataController.shared.deleteAllEntries()
                stats = [DataController.shared.getNewStatisticsEntry()]
            }
        }
        setupBarChart()
        setupLabels()
    }
    
    // MARK: - Functions
    
    func setupBarChart(){
        stats = DataController.shared.getStats()
        var datasets = [BarChartDataSet]()
        print(stats)
        datasets.reserveCapacity(7)
        
        for (index, day) in stats.enumerated() {
            let newEntry = BarChartDataEntry(x: Double(index) + 1.0, y: day.averageSpeed)
            let weekday = Calendar.current.component(.weekday, from: Date(timeIntervalSinceReferenceDate: day.creationTime as TimeInterval))
            let chartDataSet = BarChartDataSet(entries: [newEntry], label: weekdays[weekday])
            chartDataSet.setColors(colors[weekdays[weekday] ?? Monday] ?? .blue)
            datasets.append(chartDataSet)
        }
        let chartData = BarChartData(dataSets: datasets)
        barChart.data = datasets.isEmpty ? nil : chartData
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    func setupLabels() {
        guard let todayStat = DataController.shared.getStats().last else {
            return
        }
        if let maxStat = stats.max(by: {$0.averageSpeed < $1.averageSpeed}), defaults.double(forKey: "maxReadingSpeed") < maxStat.averageSpeed {
            defaults.set(maxStat.averageSpeed, forKey: "maxReadingSpeed")
        }
        let localizedWords = NSLocalizedString(" words", comment: "part 2 of todayLabel")
        let localizedMinutes = NSLocalizedString(" minutes", comment: "part 2 of timeEconomyLabel")
        let localizedWPM = NSLocalizedString(" words/min", comment: "words per minute")
        let localizedWordsCount = NSLocalizedString("Total words count: ", comment: "wordsCountLabel text")
        let localizedTotalTime = NSLocalizedString("Total time of reading: ", comment: "timeOfReadingLabel text")
        let localizedTodayLabel = NSLocalizedString("Read today: ", comment: "readTodayLabel text")
        let localizedMaxSpeed = NSLocalizedString("Max reading speed: ", comment: "maxSpeedLabel text")
        let localizedTimeEconomy = NSLocalizedString("Time economy: ", comment: "timeEconomyLabel text")
        wordsCountLabel.text = localizedWordsCount + String(defaults.integer(forKey: "wordsCount")) + localizedWords
        
        if let time = defaults.value(forKey: "totalTimeOfReading") as? Double {
            timeOfReadingLabel.text = localizedTotalTime + " " + String(Int(time.rounded() / 60.0)) + localizedMinutes
            let words = defaults.integer(forKey: "wordsCount")
            timeEconomyLabel.text = localizedTimeEconomy + String(Int(Double(words) / 150.0 - time / 60.0)) + localizedMinutes
        }
        
        maxReadingSpeedLabel.text = localizedMaxSpeed + String(Int(defaults.double(forKey: "maxReadingSpeed"))) + localizedWPM
        let date = Date(timeIntervalSinceReferenceDate: todayStat.creationTime)
        let calendar = Calendar.current
        if calendar.component(.weekday, from: date) == calendar.component(.weekday, from: Date()) {
            readTodayLabel.text = localizedTodayLabel + String(todayStat.wordsCount) + localizedWords
        }
        else {
            readTodayLabel.text = localizedTodayLabel + "0" + localizedWords
        }
    }
}

// MARK: - Dark mode

extension MyProfileViewController: DarkModeApplicable {
    func toggleDarkMode() {
        if let version = Int(String(systemVersion)), version<13 {
            readTodayLabel.textColor = .white
            wordsCountLabel.textColor = .white
            timeOfReadingLabel.textColor = .white
            maxReadingSpeedLabel.textColor = .white
            timeEconomyLabel.textColor = .white
            view.backgroundColor = .black
        }
    }
    
    func toggleLightMode() {
        if let version = Int(String(systemVersion)), version<13 {
            readTodayLabel.textColor = .black
            wordsCountLabel.textColor = .black
            timeOfReadingLabel.textColor = .black
            maxReadingSpeedLabel.textColor = .black
            timeEconomyLabel.textColor = .black
            view.backgroundColor = .white
        }
    }
}
