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
    var text: [String]
    var position: Int
    init(named name: String, withText text: [String]) {
        self.name = name
        self.text = text
        self.position = 0
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(text, forKey: "Text")
        aCoder.encode(position, forKey: "Position")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "Name") as! String
        self.text = aDecoder.decodeObject(forKey: "Text") as! [String]
        self.position = aDecoder.decodeInteger(forKey: "Position")
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
    func getAttributedWord() -> NSMutableAttributedString {
        let word = NSMutableAttributedString(string: text[position])
        position+=1
        word.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: getRedLetterPosition(word.length), length: 1))
        return word
    }
}
