//
//  WelcomePageViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 26/10/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class WelcomePageViewController: UIPageViewController {
    private lazy var welcomeControllers: [UIViewController] = {
        var controllers = [
            getWelcomeController(withIndex: 1),
            getWelcomeController(withIndex: 3)
        ]
        if let version = Int(String(systemVersion)), version<13 {
            controllers.insert(getWelcomeController(withIndex: 2), at: 1)
        }
        return controllers
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        if let firstViewController = welcomeControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        else{
            print("viewControllers not set")
        }
    }
    
    func getWelcomeController(withIndex index: Int) -> UIViewController{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Welcome\(index)ViewController")
        
    }
}

extension WelcomePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = welcomeControllers.firstIndex(of: viewController) else {
            print("Index not found")
            return nil
        }
        if index>0 {
            print("index before is \(index-1)")
            return welcomeControllers[index-1]
        }
        else {
            print("No index before")
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = welcomeControllers.firstIndex(of: viewController) else {
            print("Index not found")
            return nil
        }
        if index != (welcomeControllers.count - 1) {
            print("Index after is \(index+1)")
            return welcomeControllers[index+1]
        }
        else {
            print("No index after")
            return nil
        }
    }
    
    
}
