//
//  DataController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 30/06/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataController {
    // MARK: - Constants
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let shared = DataController()
    var lastSavedBook: Book?
    
    
    private init() {}
    
    // MARK: - Managing books
    func getBook(named name: String) -> Book? {
        let request = Book.fetchRequest() as NSFetchRequest<Book>
        let predicate = NSPredicate(format: "name = %@", name)
        request.predicate = predicate
        
        do {
            let book = try context.fetch(request)
            if book.isEmpty {
                return nil
            }
            return book[0]
        }
        catch {
            print("-> Error while fetching book: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getLibrary() -> [Book] {
        var library = [Book]()
        let request = Book.fetchRequest() as NSFetchRequest<Book>
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        let sortByAuthor = NSSortDescriptor(key: "author", ascending: true)
        request.sortDescriptors = [sortByName, sortByAuthor]
        do {
            library = try context.fetch(request)
        }
        catch {
            print("-> Error while fetching library: \(error.localizedDescription)")
        }
        return library
    }
    
    func saveData() {
        appDelegate.saveContext()
    }
    
    func saveBook(named name: String, withText text: String, by author: String, withPosition position: Int = 0) {
        let book = Book(entity: Book.entity(), insertInto: context)
        
        book.name = name
        book.author = author
        book.text = text
        book.separatedText = text.components(separatedBy: .whitespacesAndNewlines).filter{!$0.isEmpty && $0 != " "}
        book.position = Int64(position)
        
        do {
            try context.save()
            lastSavedBook = book
        }
        catch {
            print("-> Unexpected error when trying to save a book: \(error.localizedDescription)")
        }
    }
    
    func deleteBook(_ book: Book){
        context.delete(book)
    }
    
    // MARK: - Managing statistics
    
    func getNewStatisticsEntry() -> StatisticsEntry {
        let stat = StatisticsEntry(entity: StatisticsEntry.entity(), insertInto: context)
        stat.averageSpeed = 0.0
        stat.creationTime = Date().timeIntervalSinceReferenceDate
        stat.readingTime = 0.0
        stat.wordsCount = 0
        let currentWeekday = Calendar.current.component(.weekday, from: Date())
        UserDefaults.standard.set(currentWeekday, forKey: "lastExitDay")
        let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
        UserDefaults.standard.set(currentWeek, forKey: "lastExitWeek")
        print("made a new stat")
        return stat
    }
    
    func saveStat(words: Int, time: Double){
        let stat = StatisticsEntry(entity: StatisticsEntry.entity(), insertInto: context)
        stat.wordsCount = Int64(words)
        stat.readingTime = time
        if time != 0 {
            stat.averageSpeed = Double(words) / time
        }
        else {
            stat.averageSpeed = 0
        }
        stat.creationTime = Date().timeIntervalSinceReferenceDate
        
        do {
            try context.save()
        }
        catch {
            print("-> Unexpected error when trying to save a statisticsEntry: \(error.localizedDescription)")
        }
    }
    
    func getStats() -> [StatisticsEntry] {
        let fetchRequest = StatisticsEntry.fetchRequest() as NSFetchRequest<StatisticsEntry>
        let sortByCreationTime = NSSortDescriptor(key: "creationTime", ascending: true)
        fetchRequest.sortDescriptors = [sortByCreationTime]
        var stats = [StatisticsEntry]()
        do {
            try stats = context.fetch(fetchRequest)
        }
        catch {
            print("-> Error while fetching stats: \(error.localizedDescription)")
        }
        return stats
    }
    
    func deleteStatisticsEntry(_ entry: StatisticsEntry){
        context.delete(entry)
    }
    
    func deleteAllEntries() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StatisticsEntry")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        }
        catch {
            print("Error in deleteAllEntries")
        }
    }
}
