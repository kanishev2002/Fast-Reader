//
//  BookDetailViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 08/07/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {
    
    
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var fastReadItButton: UIButton!
    @IBOutlet weak var percentageLabel: UILabel!
    
    
    @IBAction func editButtonTouched(_ sender: UIBarButtonItem) {
        changeEditingMode()
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        navigationController?.present(pickerController, animated: true, completion: nil)
    }
    
    
    var book: Book?
    var keyboardHeight: CGFloat?
    var editModeEnabled = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let book = book {
            let position = Double(book.position)
            let wordsCount = Double(book.text!.count)
            let localizedPercentageLabel = NSLocalizedString("Read: \(Int((position/wordsCount)*100.0))%", comment: "Percentage label")
            percentageLabel.text = localizedPercentageLabel
        }
        if let theme = UserDefaults.standard.string(forKey: "Theme"), theme == "Dark" {
            toggleDarkMode()
        }
        else {
            toggleLightMode()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        nameTextField.delegate = self
        authorTextField.delegate = self
        addImageButton.isHidden = true
        navigationItem.setHidesBackButton(false, animated: true)
        authorTextField.isUserInteractionEnabled = false
        nameTextField.isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(prepareForBackground), name: NSNotification.Name("applicationWillResignActive"), object: nil)
        
        if let book = book {
            nameTextField.text = book.name
            authorTextField.text = book.author
            if let imageData = book.image {
                bookImageView.image = UIImage(data: imageData)
            }
            else {
                addImageButton.isHidden = false
            }
            textView.text = book.text?.joined(separator: " ")
        }
        else {
            print("BookDetailViewController didn't get book")
            fastReadItButton.isEnabled = false
        }
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(imageViewWasTouched))
        bookImageView.addGestureRecognizer(tapGR)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if editModeEnabled {
            changeEditingMode()
        }
        /*if let book = book {
            book.text = textView.text.components(separatedBy: .whitespacesAndNewlines).filter{!$0.isEmpty && $0 != " "}
            book.image = bookImageView.image?.pngData()
        }
        DataController.shared.saveData()*/
        //NotificationCenter.default.post(Notification(name: Notification.Name("libraryShouldUpdate")))
        //NotificationCenter.default.post(name: Notification.Name("libraryShouldUpdate"), object: nil, userInfo: ["name" : nameTextField.text!])
    }
    
    
    @objc func imageViewWasTouched() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        navigationController?.present(pickerController, animated: true, completion: nil)
    }
    
    @objc func prepareForBackground() {
        if editModeEnabled {
            changeEditingMode()
        }
        DataController.shared.saveData()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        //print("keyboardWillShow was called")
        guard keyboardHeight == nil else {
            return
        }
        //print("Keyboard was shown")
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardRect.height
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            //print("Keyboard height is \(keyboardHeight!)")
        }
        else {
            print("Error in keyboardWillShow")
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        //print("Keyboard was hidden")
        if let height = keyboardHeight, !editModeEnabled {
            view.frame.origin.y += height
        }
        else {
            print("Error in keyboardWillHide")
        }
    }
    
    func changeEditingMode() {
        if !editModeEnabled {
            navigationItem.setHidesBackButton(true, animated: true)
            authorTextField.isUserInteractionEnabled = true
            nameTextField.isUserInteractionEnabled = true
            nameTextField.becomeFirstResponder()
            editModeEnabled = true
        }
        else {
            navigationItem.setHidesBackButton(false, animated: true)
            if authorTextField.isFirstResponder {
                authorTextField.resignFirstResponder()
            }
            else if nameTextField.isFirstResponder {
                nameTextField.resignFirstResponder()
            }
            if let book = book, let nameText = nameTextField.text, !nameText.isEmpty, let authorText = authorTextField.text, !authorText.isEmpty {
                book.author = authorText
                book.name = nameText
            }
            authorTextField.isUserInteractionEnabled = false
            nameTextField.isUserInteractionEnabled = false
            editModeEnabled = false
            DataController.shared.saveData()
            //NotificationCenter.default.post(Notification(name: Notification.Name("libraryShouldUpdate")))
            NotificationCenter.default.post(name: Notification.Name("libraryShouldUpdate"), object: nil, userInfo: ["name" : nameTextField.text!])
        }
        let disableLocalized = NSLocalizedString("Disable editing", comment: "editButtonTitle")
        let enableLocalized = NSLocalizedString("Enable editing", comment: "editButtonTitle")
        editButton.title = editModeEnabled ? disableLocalized : enableLocalized
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BookDetailToFastreadingInterface" {
            if let destinationVC = segue.destination as? FastReadingInterfaceViewController {
                if let book = book {
                    book.text = textView.text.components(separatedBy: .whitespacesAndNewlines).filter{!$0.isEmpty && $0 != " "}
                    book.image = bookImageView.image?.pngData()
                }
                DataController.shared.saveData()
                destinationVC.savedBook = book
                destinationVC.didComeFromBookDetails = true
                destinationVC.text = book!.text
                destinationVC.position = Int(book!.position)
            }
        }
    }

}

extension BookDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            bookImageView.image = image
            addImageButton.isHidden = true
            if let book = book {
                book.image = image.pngData()
            }
            DataController.shared.saveData()
            NotificationCenter.default.post(name: Notification.Name("libraryShouldUpdate"), object: nil, userInfo: ["name" : nameTextField.text!])
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension BookDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
        if let height = keyboardHeight {
            UIView.animate(withDuration: 0.5) {
                self.view.frame.origin.y -= height
            }
        }
        else {
            print("No keyboard height found in textView")
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        if let book = book {
            book.text = textView.text.components(separatedBy: .whitespacesAndNewlines).filter{!$0.isEmpty && $0 != " "}
        }
        DataController.shared.saveData()
    }
}

extension BookDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}

extension BookDetailViewController: DarkModeApplicable {
    func toggleLightMode() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = UIButton(type: .system).tintColor
        navigationController?.navigationBar.isTranslucent = true
        nameTextField.textColor = .black
        authorTextField.textColor = .black
        textView.backgroundColor = .white
        textView.textColor = .black
        percentageLabel.textColor = .black
    }
    
    func toggleDarkMode() {
        let tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        view.backgroundColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.navigationBar.isTranslucent = false
        nameTextField.textColor = .white
        authorTextField.textColor = .white
        textView.backgroundColor = .black
        textView.textColor = .white
        percentageLabel.textColor = .white
    }
}
