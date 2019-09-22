//
//  AppDelegate.swift
//  Fast Reader
//
//  Created by Илья Канищев on 05/12/2018.
//  Copyright © 2018 Илья Канищев. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LibraryStorage")
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                fatalError("-> Error occured: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(Notification(name: Notification.Name("applicationWillResignActive")))
        /*if let lastExitTime = UserDefaults.standard.value(forKey: "lastExitTime") as? Date, Date().timeIntervalSince(lastExitTime) >= 24*60*60 {
            
        }*/
        /*UserDefaults.standard.set(Date(), forKey: "lastExitTime")
        UserDefaults.standard.set(Calendar.current.component(.weekday, from: Date()), forKey: "lastExitDay")
        UserDefaults.standard.set(Calendar.current.component(.weekOfYear, from: Date()), forKey: "lastExitWeek")*/
        // print("Did save exit time")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.set(Date(), forKey: "lastExitTime")
        UserDefaults.standard.set(Calendar.current.component(.weekday, from: Date()), forKey: "lastExitDay")
        UserDefaults.standard.set(Calendar.current.component(.weekOfYear, from: Date()), forKey: "lastExitWeek")
        // print("Did save exit time")
    }


}

