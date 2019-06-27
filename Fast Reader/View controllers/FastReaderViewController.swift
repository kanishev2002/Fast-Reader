//
//  FastReaderViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 27/12/2018.
//  Copyright © 2018 Илья Канищев. All rights reserved.
//

import UIKit

class FastReaderViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var readItButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
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
    
    /*override func viewWillAppear(_ animated: Bool) {
        configureTheme()
    }*/
    
    
    @IBOutlet weak var inputTextView: UITextView!{
        didSet
        {
            inputTextView.delegate=self
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func toggleDarkMode() {
        view.backgroundColor = .black
        inputTextView.textColor = .white
        inputTextView.backgroundColor = .black
        tabBarController?.tabBar.barTintColor = .black
        tabBarController?.tabBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .black
    }
    
    @objc func toggleLightMode() {
        view.backgroundColor = .white
        if inputTextView.text == "Input your text here..." {
            inputTextView.textColor = .lightGray
        }
        else {
            inputTextView.textColor = .black
        }
        inputTextView.backgroundColor = .white
        tabBarController?.tabBar.barTintColor = .white
        tabBarController?.tabBar.tintColor = .blue
        navigationController?.navigationBar.barTintColor = .white
    }
    
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputTextView.becomeFirstResponder()
        if inputTextView.text == "Input your text here..." {
            inputTextView.text = ""
        }
        else if textView.text == "" {
            inputTextView.text = "Input your text here..."
            inputTextView.textColor = .lightGray
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
    }
    
    func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory = path.appendingPathComponent("PrivateDocuments")
        do{
            try FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            print("Couldn't create directory")
        }
        return documentsDirectory
    }
    
    func saveAsBook() {
        let alertController = UIAlertController(title: "Сохранить как...", message: "Введите название и автора книги", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Название книги"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Имя автора"
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let documentsDirectory = getDocumentsDirectory()
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
            
            guard let name = alertController.textFields?.first!.text, let author = alertController.textFields?.last!.text, !name.isEmpty, !author.isEmpty else {
               return
            }
            
            let newBook = Book(named: name, withText: self.inputTextView.text.components(separatedBy: .whitespacesAndNewlines), by: author)
        })
        alertController.addAction(okAction)
        // Present alert controller
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Fastreading button was pressed"
        {
            if let destinationVC = segue.destination as? FastReadingInterfaceViewController
            {
                destinationVC.book = Book(named: "default", withText: inputTextView.text.components(separatedBy: CharacterSet.whitespacesAndNewlines), by: "John Doe")
            }
        }
    }
    
    /*func configureTheme() {
     let defaults = UserDefaults.standard
     if let theme = defaults.string(forKey: "Theme"), theme == "Dark"{
     view.backgroundColor = .black
     inputTextView.textColor = .white
     inputTextView.backgroundColor = .black
     tabBarController?.tabBar.barTintColor = .black
     tabBarController?.tabBar.tintColor = .white
     navigationController?.navigationBar.barTintColor = .black
     }
     else {
     view.backgroundColor = .white
     if inputTextView.text == "Input your text here..." {
     inputTextView.textColor = .lightGray
     }
     else {
     inputTextView.textColor = .black
     }
     inputTextView.backgroundColor = .white
     tabBarController?.tabBar.barTintColor = .white
     tabBarController?.tabBar.tintColor = .blue
     navigationController?.navigationBar.barTintColor = .white
     }
     }*/
}
