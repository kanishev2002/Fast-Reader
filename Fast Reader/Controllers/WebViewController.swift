//
//  WebViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 29/08/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    //var webView: WKWebView!
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    /*override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        view.translatesAutoresizingMaskIntoConstraints = false
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureToolbar()
    }

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
        webView.allowsBackForwardNavigationGestures = true
        let url = URL(string: "https://google.com")!
        webView.load(URLRequest(url: url))
        configureToolbar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "FR!", style: .plain, target: self, action: #selector(fastreadingButtonTouched))
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        navigationItem.title = webView.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.isHidden = (webView.estimatedProgress == 1)
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let localizedError = NSLocalizedString("Error", comment: "alert title")
        let alert = UIAlertController(title: localizedError, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func reloadPage() {
        webView.reload()
    }
    
    @objc func goToPage(){
        let alertController = UIAlertController(title: "Go to...", message: nil, preferredStyle: .alert)
        alertController.addTextField { (field) in
            field.placeholder = "Input URL"
        }
        let titles = [NSLocalizedString("Go", comment: "alert action button"), NSLocalizedString("Cancel", comment: "alert action button")]
        alertController.addAction(UIAlertAction(title: titles[0], style: .default, handler: { (action) in
            guard let textField = alertController.textFields!.first, let text = textField.text else {
                return
            }
            
            if let url = URL(string: text), text.hasPrefix("https://") {
                self.webView.load(URLRequest(url: url))
            }
            else if let url = URL(string: "https://" + text) {
                self.webView.load(URLRequest(url: url))
            }
        }))
        alertController.addAction(UIAlertAction(title: titles[1], style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func fastreadingButtonTouched() {
        if let contentsOfWebsite = try? NSAttributedString(data: Data(contentsOf: webView.url!), options: [.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil) {
            performSegue(withIdentifier: "webViewToFastReadingInterface", sender: contentsOfWebsite.string)
        }
        else {
            let localizedTitle = NSLocalizedString("Error", comment: "Alert title")
            let localizedMessage = NSLocalizedString("An error occured while fetching text from website. Please, try again.", comment: "Alert message")
            let alert = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        progressView.setProgress(0.0, animated: false)
    }
    
    func configureToolbar() {
        let reloadItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadPage))
        let gotoItem = UIBarButtonItem(title: "Go to...", style: .plain, target: self, action: #selector(goToPage))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [reloadItem, flexibleSpace, gotoItem]
        navigationController?.isToolbarHidden = false
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "webViewToFastReadingInterface" {
            if let destinationVC = segue.destination as? FastReadingInterfaceViewController {
                if let senderString = sender as? String {
                    print(senderString)
                    destinationVC.savedBook = nil
                    destinationVC.didComeFromBookDetails = false
                    destinationVC.text = senderString.components(separatedBy: .whitespacesAndNewlines).filter{!$0.isEmpty && $0 != " "}
                    destinationVC.position = 0
                }
            }
        }
    }

}

extension WebViewController: DarkModeApplicable{
    func toggleDarkMode() {
        navigationController?.toolbar.tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        navigationController?.toolbar.barTintColor = .black
        //navigationController?.toolbar.backgroundColor = .black
        view.backgroundColor = .black
        tabBarController?.tabBar.barTintColor = .black
        tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
    }
    
    func toggleLightMode() {
        navigationController?.toolbar.tintColor = UIButton(type: .system).tintColor
        navigationController?.toolbar.barTintColor = .white
        //navigationController?.toolbar.backgroundColor = .white
        view.backgroundColor = .white
        tabBarController?.tabBar.barTintColor = .white
        tabBarController?.tabBar.tintColor = UIButton(type: .system).tintColor
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
    }
    
    
}
