//
//  FastReaderViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 27/12/2018.
//  Copyright © 2018 Илья Канищев. All rights reserved.
//

import UIKit

class FastReaderViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var ReadItButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let LocallizedButton = NSLocalizedString("Fast Read it!", comment: "Bottom Button")
        ReadItButton.setTitle(LocallizedButton, for: .normal)
    }
    
    
    @IBOutlet weak var InputTextView: UITextView!
    {
        didSet
        {
            InputTextView.delegate=self
        }
    }
    
    
    
    @IBAction func ButtonTouched(_ sender: UIButton) {
        
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        InputTextView.becomeFirstResponder()
        InputTextView.text = ""
        InputTextView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        InputTextView.resignFirstResponder()
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
        let alertController = UIAlertController(title: "Save as...", message: "Input name of the book", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let documentsDirectory = getDocumentsDirectory()
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
            let nameOfBook = alertController.textFields?.first!.text
            if let name = nameOfBook{
                let book = Book(named: name, withText: self.InputTextView.text.components(separatedBy: CharacterSet.whitespacesAndNewlines))
                let codedBook = NSKeyedArchiver.archivedData(withRootObject: book)
                do{
                    try codedBook.write(to: documentsDirectory)
                }
                catch
                {
                    print("Unable to write to directory " + error.localizedDescription)
                }
            }
        })
        alertController.addAction(okAction)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Fastreading button was pressed"
        {
            if let destinationVC = segue.destination as? FastReadingInterfaceViewController
            {
                destinationVC.textToRead = InputTextView.text.components(separatedBy: " ")
            }
        }
    }
}
