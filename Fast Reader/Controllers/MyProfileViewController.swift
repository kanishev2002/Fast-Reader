//
//  BarChartViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 11/08/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit
import Charts

fileprivate let weekdays = [
    -6 : "Sat",
    -5 : "Mon",
    -4 : "Tue",
    -3 : "Wed",
    -2 : "Thu",
    -1 : "Fri",
    0 : "Sat",
    1 : "Sun",
    2 : "Mon",
    3 : "Tue",
    4 : "Wed",
    5 : "Thu",
    6 : "Fri",
    7 : "Sat"
]

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var readTodayLabel: UILabel!
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var timeOfReadingLabel: UILabel!
    @IBOutlet weak var maxReadingSpeedLabel: UILabel!
    @IBOutlet weak var timeEconomyLabel: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    var stats = DataController.shared.getStats()
    var viewControllerWasLoaded = false
    let defaults = UserDefaults.standard
    
    
    override func viewWillAppear(_ animated: Bool) {
        if viewControllerWasLoaded {
            setupBarChart()
            setupLabels()
            //print("viewWillAppear was called")
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
        /*if let theme = defaults.string(forKey: "Theme"), theme == "Dark"{
            toggleDarkMode()
        }
        else {
            toggleLightMode()
        }*/
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
                /*for _ in 0 ..< min(7, (currentWeek-lastExitWeek)*7 + currentWeekday - lastExitDay) {
                    DataController.shared.saveStat(words: 0, time: 0)
                    print("MPVC Added an empty stat")
                }
                stats = DataController.shared.getStats()
                print("Number of stats: \(stats.count)")
                if stats.count > 7 {
                    for i in 0 ..< stats.count - 7 {
                        DataController.shared.deleteStatisticsEntry(stats[i])
                        print("MPVC deleted a stat")
                    }
                    print("MPVC: Number of stats \(DataController.shared.getStats().count)")
                    stats = DataController.shared.getStats()
                    
                }*/
                DataController.shared.deleteAllEntries()
                stats = [DataController.shared.getNewStatisticsEntry()]
            }
        }
        setupBarChart()
        setupLabels()
    }
    
    func setupBarChart(){
        //let weekday = Calendar.current.component(.weekday, from: Date())
        stats = DataController.shared.getStats()
        var datasets = [BarChartDataSet]()
        print(stats)
        datasets.reserveCapacity(7)
        let chartDataColor: UIColor
        if let theme = defaults.string(forKey: "Theme"), theme == "Dark" {
            chartDataColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        }
        else {
            chartDataColor = .blue
        }
        for (index, day) in stats.enumerated() {
            let newEntry = BarChartDataEntry(x: Double(index) + 1.0, y: day.averageSpeed)
            let weekday = Calendar.current.component(.weekday, from: Date(timeIntervalSinceReferenceDate: day.creationTime as TimeInterval))
            let chartDataSet = BarChartDataSet(entries: [newEntry], label: weekdays[weekday])
            chartDataSet.setColors(chartDataColor)
            datasets.append(chartDataSet)
        }
        //let localizedChartName = NSLocalizedString("Average reading speed", comment: "Reading speed chart name")
        let chartData = BarChartData(dataSets: datasets)
        //chartData.setValueTextColor(.white)
        barChart.data = datasets.isEmpty ? nil : chartData
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 2.0)
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
            timeOfReadingLabel.text = localizedTotalTime + String(Int(time.rounded() / 60.0)) + localizedMinutes
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


extension MyProfileViewController: DarkModeApplicable {
    func toggleDarkMode() {
        //barChart.gridBackgroundColor = .green
        //barChart.tintColor = .white
        //barChart.backgroundColor = .white
        //barChart.borderColor = .white
        view.backgroundColor = .lightGray
    }
    
    func toggleLightMode() {
        view.backgroundColor = .white
    }
}
