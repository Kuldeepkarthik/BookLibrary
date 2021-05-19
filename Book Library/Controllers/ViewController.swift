//
//  ViewController.swift
//  Book Library
//
//  Created by Kuldeep Kumar P on 04/12/20.
//  Copyright © 2020 Kuldeep Kumar P. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var genresTableView: UITableView!
    
    let genresArray = ["Fantasy", "Adventure", "Romance", "Mystery", "Cooking", "Art", "History", "Travel", "Humor"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        self.genresTableView.delegate = self;
        self.genresTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "My Book Shelf"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationItem.title = self.genresArray[indexPath.row]
        booksCollectionViewController.genre = self.genresArray[indexPath.row]
    }

    // MARK: Table view delegate methods
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Library"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.genresArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genresCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        cell.textLabel?.text = self.genresArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                selectedCell.backgroundColor = UIColor.systemBlue
            })
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                selectedCell.backgroundColor = UIColor.clear
            })
        }
    }
}


