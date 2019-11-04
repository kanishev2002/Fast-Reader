//
//  Welcome3ViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 30/10/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit

class Welcome3ViewController: UIViewController {
    
    @IBOutlet weak var exampleTextLabel: UILabel!
    @IBOutlet weak var fontPicker: UIPickerView!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var fontSizeLabel: UILabel!
    
    @IBAction func cancelAction(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(Double(fontSizeSlider.value.rounded()), forKey: "Default font size")
        defaults.set(fonts[fontPicker.selectedRow(inComponent: 0)], forKey: "Default font")
        self.parent?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    let localizedExampleText = NSLocalizedString("This is example text", comment: "Example text")
    let localizedFontSize = NSLocalizedString("Font size: ", comment: "Font size label")
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        exampleTextLabel.attributedText = NSAttributedString(string: localizedExampleText, attributes: [
            .font : UIFont(name: fonts[fontPicker.selectedRow(inComponent: 0)], size: CGFloat(sender.value.rounded()))!
        ])
        fontSizeLabel.text = localizedFontSize + String(Int(sender.value.rounded()))
    }
    
    
    var fonts: [String] = {
        var fonts = [String]()
        for family in UIFont.familyNames{
            fonts.append(contentsOf: UIFont.fontNames(forFamilyName: family))
        }
        fonts.sort()
        return fonts
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exampleTextLabel.attributedText = NSAttributedString(string: localizedExampleText, attributes: [
            .font : UIFont(name: fonts[fontPicker.selectedRow(inComponent: 0)], size: CGFloat(fontSizeSlider.value.rounded()))!
        ])
        fontSizeLabel.text = localizedFontSize + String(Int(fontSizeSlider.value.rounded()))
        
        fontPicker.delegate = self
        fontPicker.dataSource = self
    }
    
}

extension Welcome3ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        fonts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let font = NSAttributedString(string: fonts[row], attributes: [
            .font: UIFont(name: fonts[row], size: 17.0)!
        ])
        return font
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        exampleTextLabel.attributedText = NSAttributedString(string: localizedExampleText, attributes: [
            .font : UIFont(name: fonts[row], size: CGFloat(fontSizeSlider.value.rounded()))!
        ])
    }
}
