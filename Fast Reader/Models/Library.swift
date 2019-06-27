//
//  Library.swift
//  Fast Reader
//
//  Created by Илья Канищев on 23/06/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import Foundation

class Library: NSObject, NSCoding {
    var books: [Book]
    
    override init() {
        self.books = []
    }
    
    func addBook(_ book: Book) {
        books.append(book)
    }
    
    // MARK: - NSCoding protocol
    required init?(coder aDecoder: NSCoder) {
        self.books = aDecoder.decodeObject(forKey: "Books") as! [Book]
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(books, forKey: "Books")
    }
}
