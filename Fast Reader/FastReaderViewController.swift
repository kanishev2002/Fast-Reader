//
//  FastReaderViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 27/12/2018.
//  Copyright © 2018 Илья Канищев. All rights reserved.
//

import UIKit

class FastReaderViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var InputTextField: UITextField!
        {
        didSet{
            InputTextField.delegate = self
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        InputTextField.resignFirstResponder()
        return true
    }
}
