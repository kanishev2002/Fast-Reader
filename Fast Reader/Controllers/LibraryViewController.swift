//
//  LibraryViewController.swift
//  Fast Reader
//
//  Created by Илья Канищев on 25/06/2019.
//  Copyright © 2019 Илья Канищев. All rights reserved.
//

import UIKit
import CoreData

class LibraryViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Variables
    
    private var library = [Book]()
    private var searchResults = [Book]()
    private var colorOfCells = UIColor.white
    private var selectedBook: Book? = nil
    
    // MARK: - Managing views
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(libraryShouldUpdate), name: Notification.Name("libraryShouldUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLightMode), name: .darkModeDisabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleDarkMode), name: .darkModeEnabled, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        library = DataController.shared.getLibrary()
        searchResults = library
        tableView.rowHeight = 76.0
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshDidFire), for: .valueChanged)
        tableView.refreshControl = refreshControl
        navigationItem.rightBarButtonItem = editButtonItem
        searchBar.delegate = self
        searchBar.barStyle = .default
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath) as! LibraryCell
        if let imageData = searchResults[indexPath.row].image {
            cell.bookImage.image = UIImage(data: imageData)
        }
        let localizedAuthor = NSLocalizedString("Unknown author", comment: "")
        let localizedBook = NSLocalizedString("Unknown book", comment: "")
        cell.authorLabel.text = searchResults[indexPath.row].author ?? localizedAuthor
        cell.nameLabel.text = searchResults[indexPath.row].name ?? localizedBook
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = searchResults[indexPath.row]
        performSegue(withIdentifier: "LibraryCellToBookDetails", sender: self)
        
        print(indexPath.row)
        print(selectedBook!.name!)
        print(selectedBook!.author!)
        print(selectedBook!.position)
        print(selectedBook!.separatedText!.count)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let version = Int(String(systemVersion)), version<13 {
            let libraryCell = cell as! LibraryCell
            if colorOfCells == .white {
                libraryCell.authorLabel.textColor = .black
                libraryCell.nameLabel.textColor = .black
            }
            else {
                let tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                libraryCell.authorLabel.textColor = tintColor
                libraryCell.nameLabel.textColor = tintColor
            }
            libraryCell.backgroundColor = colorOfCells
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataController.shared.deleteBook(searchResults[indexPath.row])
            library.remove(at: library.firstIndex(of: searchResults[indexPath.row])!)
            searchResults.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            DataController.shared.saveData()
        }
    }
    
    // MARK: - @Objc funcs
    
    @objc func libraryShouldUpdate(_ notification: Notification?) {
        guard let notification = notification else {
            print("No notification")
            library = DataController.shared.getLibrary()
            searchResults = library
            tableView.reloadData()
            return
        }
        if let userInfo = notification.userInfo {
            if let index = searchResults.firstIndex(where: { $0.name! == (userInfo["name"] as! String) }) {
                let indexPath = IndexPath(row: index, section: 0)
                print("Found book with name \(userInfo["name"] as! String). Its index is \(index), Indexpath: \(indexPath)")
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            else {
                print("No book with name \(userInfo["name"] as! String)")
            }
        }
        else {
            print("No user info")
        }
    }
    
    @objc func refreshDidFire() {
        if !isEditing {
            ImportController.shared.importAllFiles()
            libraryShouldUpdate(nil)
        }
        tableView.refreshControl?.endRefreshing()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LibraryCellToBookDetails" {
            if let destinationVC = segue.destination as? BookDetailViewController {
                destinationVC.book = selectedBook ?? nil
            }
            else {
                print("No destinatonVC")
            }
        }
        else {
            print("LibraryCellToBookDetails failed to complete")
        }
    }
    
}

// MARK: - UISearchBarDelegate

extension LibraryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults = library
        }
        else {
            searchResults = library.filter{
                $0.name!.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            searchBar.resignFirstResponder()
            return false
        }
        return true
    }
}

// MARK: - Dark Mode

extension LibraryViewController: DarkModeApplicable {
    func toggleLightMode() {
        if let version = Int(String(systemVersion)), version<13 {
            colorOfCells = .white
            view.backgroundColor = .white
            tableView.backgroundColor = .white
            tabBarController?.tabBar.barTintColor = .white
            tabBarController?.tabBar.tintColor = systemButtonColor
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
            navigationController?.navigationBar.tintColor = systemButtonColor
            editButtonItem.tintColor = systemButtonColor
            searchBar.tintColor = .black
            searchBar.barStyle = .default
            tableView.reloadData()
        }
    }
    
    func toggleDarkMode() {
        if let version = Int(String(systemVersion)), version<13 {
            colorOfCells = .black
            view.backgroundColor = .black
            tableView.backgroundColor = .black
            tabBarController?.tabBar.barTintColor = .black
            tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            navigationController?.navigationBar.barTintColor = .black
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
            editButtonItem.tintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            searchBar.tintColor = .white
            searchBar.barStyle = .black
            tableView.reloadData()
        }
    }
}
