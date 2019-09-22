//
//  ImportController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 21/07/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import Foundation
import PDFKit
//import EPUBKit

class ImportController {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let fileManager = FileManager.default
    static let shared = ImportController()
    private init() {}
    let localizedAuthor = NSLocalizedString("Unknown author", comment: "Unknown author")
    
    
    func importAllFiles() {
        importPDFFiles()
        importTXTFiles()
        //importEpubFiles()
        importRTFFiles()
    }
    
    func importPDFFiles() {
        do {
            let directoryContent = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let PDFFiles = directoryContent.filter { $0.pathExtension == "pdf"}
            for URL in PDFFiles {
                if let pdf = PDFDocument(url: URL), let text = pdf.string {
                    
                    DataController.shared.saveBook(named: URL.deletingPathExtension().lastPathComponent, withText: text.components(separatedBy: .whitespacesAndNewlines), by: localizedAuthor)
                }
                try fileManager.removeItem(at: URL)
            }
        }
        catch {
            print("Couldn't access directory content - \(error.localizedDescription)")
        }
    }
    
    func importTXTFiles() {
        do {
            let directoryContent = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let TXTFiles = directoryContent.filter{ $0.pathExtension == "txt" }
            for URL in TXTFiles {
                do {
                    let text = try String(contentsOf: URL)
                    DataController.shared.saveBook(named: URL.deletingPathExtension().lastPathComponent, withText: text.components(separatedBy: .whitespacesAndNewlines), by: localizedAuthor)
                    try fileManager.removeItem(at: URL)
                }
                catch {
                    print("Error while importing txtFile - \(error.localizedDescription)")
                    continue
                }
            }
        }
        catch {
            print("Couldn't access directory content - \(error.localizedDescription)")
        }
    }
    
    /*func importEpubFiles() {
        do {
            let directoryContent = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let EpubFiles = directoryContent.filter{ $0.pathExtension == "epub" }
            for URL in EpubFiles {
                if let document = EPUBDocument(url: URL) {
                    let text = NSMutableAttributedString()
                    try document.spine.items.forEach {
                        guard let path = document.manifest.items[$0.idref]?.path, let url = NSURL(string: path) else { return }
                        let attributed = try NSAttributedString(data: Data(contentsOf: url as URL), options: [.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil)
                        text.append(attributed)
                    }
                    if text.length != 0 {
                        let localizedName = NSLocalizedString("Unknown name", comment: "Unknown name")
                        DataController.shared.saveBook(named: document.title ?? localizedName, withText: text.string.components(separatedBy: .whitespacesAndNewlines), by: document.author ?? localizedAuthor)
                    }
                    else {
                        print("Text is empty!")
                    }
                    try fileManager.removeItem(at: URL)
                }
            }
        }
        catch {
            print("Couldn't access directory content - \(error.localizedDescription)")
        }
    }*/
    
    func importRTFFiles() {
        do {
            let directoryContent = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let docFiles = directoryContent.filter{ $0.pathExtension == "rtf" }
            for URL in docFiles {
                do {
                    let data = try Data(contentsOf: URL)
                    let text = try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.rtf], documentAttributes: nil).string
                    DataController.shared.saveBook(named: documentsDirectory.lastPathComponent, withText: text.components(separatedBy: .whitespacesAndNewlines), by: localizedAuthor)
                    try fileManager.removeItem(at: URL)
                }
                catch {
                    print("Error while importing rtf file - \(error.localizedDescription)")
                }
            }
        }
        catch {
            print("Couldn't access directory content - \(error.localizedDescription)")
        }
    }
}
