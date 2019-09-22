//
//  FastReaderViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 27/12/2018.
//  Copyright © 2018 Илья Канищев. All rights reserved.
//

import UIKit

class FastReaderViewController: UIViewController {
    
    @IBOutlet weak var readItButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    let localizedDefaultText = NSLocalizedString("Input your text here...", comment: "default inputTextView text")
    let dataController = DataController.shared
    
    @IBAction func readItButtonTouched(_ sender: UIButton) {
        if inputTextView.text == localizedDefaultText || inputTextView.text.isEmpty {
            let localizedTitle = NSLocalizedString("Error", comment: "localized alert title")
            let localizedMessage = NSLocalizedString("You didn't input any text", comment: "localized alert message")
            let alertController = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        else {
            performSegue(withIdentifier: "Fastreading button was pressed", sender: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        
        
        // debug:
        /*dataController.deleteAllEntries()
        print("Stats cleared: \(DataController.shared.getStats().count) stats found")
         */
        //
        
        let saveButtonTitle = NSLocalizedString("Save", comment: "Save button title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: saveButtonTitle, style: .plain, target: self, action: #selector(saveButtonTouched))
        inputTextView.delegate = self
        inputTextView.text = localizedDefaultText
        let locallizedButton = NSLocalizedString("Fast Read it!", comment: "Bottom Button")
        readItButton.setTitle(locallizedButton, for: .normal)
        if let theme = UserDefaults.standard.string(forKey: "Theme") {
            if theme == "Dark" {
                view.backgroundColor = .black
                inputTextView.textColor = .white
                inputTextView.backgroundColor = .black
                NotificationCenter.default.post(Notification(name: .darkModeEnabled))
            }
        }
        else {
            NotificationCenter.default.post(Notification(name: .darkModeDisabled))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputTextView.resignFirstResponder()
        inputTextView.text = localizedDefaultText
    }
    
    @objc func saveButtonTouched() {
        guard inputTextView.text != localizedDefaultText && !inputTextView.text.isEmpty else {
            let localizedTitle = NSLocalizedString("Error", comment: "localized alert title")
            let localizedMessage = NSLocalizedString("You didn't input any text", comment: "localized alert message")
            let alertController = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }
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
            
            self.dataController.saveBook(named: name, withText: self.inputTextView!.text.components(separatedBy: .whitespacesAndNewlines), by: author, withPosition: 0)
        })
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: {
            NotificationCenter.default.post(Notification(name: Notification.Name("libraryShouldUpdate")))
        })
        print("saveAsBook function completed")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Fastreading button was pressed"
        {
            if let destinationVC = segue.destination as? FastReadingInterfaceViewController
            {
                destinationVC.savedBook = nil
                destinationVC.text = inputTextView.text.components(separatedBy: .whitespacesAndNewlines).filter{!$0.isEmpty && $0 != " "}
                destinationVC.didComeFromBookDetails = false
                destinationVC.position = 0
            }
        }
    }
}

extension FastReaderViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputTextView.becomeFirstResponder()
        if inputTextView.text == localizedDefaultText {
            inputTextView.text = ""
        }
        
        if let theme = UserDefaults.standard.string(forKey: "Theme"), theme == "Dark"{
            inputTextView.textColor = .white
        }
        else {
            inputTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        inputTextView.resignFirstResponder()
        if textView.text.isEmpty {
            textView.text = localizedDefaultText
            textView.textColor = .lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension FastReaderViewController: DarkModeApplicable {
    func toggleDarkMode() {
        let tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        view.backgroundColor = .black
        inputTextView.textColor = .white
        inputTextView.backgroundColor = .black
        inputTextView.tintColor = .white
        tabBarController?.tabBar.barTintColor = .black
        tabBarController?.tabBar.tintColor = tintColor
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
    }
    
    func toggleLightMode() {
        view.backgroundColor = .white
        if inputTextView.text == localizedDefaultText {
            inputTextView.textColor = .lightGray
        }
        else {
            inputTextView.textColor = .black
        }
        inputTextView.backgroundColor = .white
        inputTextView.tintColor = UIButton(type: .system).tintColor
        tabBarController?.tabBar.barTintColor = .white
        tabBarController?.tabBar.tintColor = UIButton(type: .system).tintColor
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
    }
}

