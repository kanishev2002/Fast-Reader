//
//  Book.swift
//  Fast Reader
//
//  Created by Илья Канищев on 28/05/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import Foundation
import UIKit

class Book: NSObject, NSCoding {
    let name: String
    let author: String
    var text: [String]
    var position: Int
    var image: UIImage?
    
    init(named name: String, withText text: [String], by author: String) {
        self.name = name
        self.text = text.filter{!$0.isEmpty && $0 != " "}
        self.position = 0
        self.author = author
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(text, forKey: "Text")
        aCoder.encode(position, forKey: "Position")
        aCoder.encode(author, forKey: "Author")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "Name") as! String
        self.text = aDecoder.decodeObject(forKey: "Text") as! [String]
        self.position = aDecoder.decodeInteger(forKey: "Position")
        self.author = aDecoder.decodeObject(forKey: "Author") as! String
    }
    
    func getRedLetterPosition(_ length: Int) -> Int
    {
        return ((length + 6) / 4) - 1
    }
    
    /*func getPreparedText() -> [NSMutableAttributedString] {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red]
        var preparedText: [NSMutableAttributedString] = []
        for word in self.text
        {
            let newWord = NSMutableAttributedString(string: word.string)
            newWord.addAttributes(attributes, range: NSRange(location: getRedLetterPosition(newWord.length), length: 1))
            preparedText.append(newWord)
        }
        return preparedText
    }*/
    func getAttributedWord() -> [NSAttributedString] {
        
        let defaults = UserDefaults.standard
        let word = text[position]
        let index = word.index(word.startIndex, offsetBy: getRedLetterPosition(word.count))
        let font: String
        
        if let defaultFont = defaults.string(forKey: "Default font"), defaults.integer(forKey: "Default font size") != 0 {
            font = defaultFont
        }
        else {
            defaults.set("Helvetica", forKey: "Default font")
            defaults.set(50, forKey: "Default font size")
            font = "Helvetica"
        }
        
        let fontSize = defaults.integer(forKey: "Default font size")
        let themeTextColor: UIColor
        if let theme = defaults.string(forKey: "Theme"), theme == "Dark" {
            themeTextColor = .white
        }
        else {
            themeTextColor = .black
        }
        let attributes: [NSAttributedString.Key: Any] = [.font : UIFont(name: font, size: CGFloat(fontSize))!, .foregroundColor : themeTextColor]
        
        let part1 = NSAttributedString(string: String(word[..<index]), attributes: attributes)
        let part2 = NSMutableAttributedString(string: String(word[index]), attributes: attributes)
        part2.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 1))
        
        let nextIndex = word.index(after: index)
        let part3 = NSAttributedString(string: String(word[nextIndex ..< word.endIndex]), attributes: attributes)
        
        let parts = [part1, part2, part3]
        position += 1
        return parts
    }
}
