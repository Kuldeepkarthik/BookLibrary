//
//  booksCollectionViewController.swift
//  Book Library
//
//  Created by Kuldeep Kumar P on 04/12/20.
//  Copyright © 2020 Kuldeep Kumar P. All rights reserved.
//

import UIKit

private let reuseIdentifier = "bookCell"

class booksCollectionViewController: UICollectionViewController, UISearchControllerDelegate {
    
    var booksList = [Book]()
    var searchedBookList = [Book]()
    var loadingIndicator = UIActivityIndicatorView()
    let services = serviceManager()
    var isSearchInProgress = false
    let searchController = UISearchController()
    
    static var genre: String!

    override func awakeFromNib() {
        super.awakeFromNib()
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        services.fetchBooksFor(genre: Genre(rawValue: booksCollectionViewController.genre)!) { BooksDataSource in
            self.booksList = BooksDataSource.results
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.searchController = self.searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numOfItems = self.booksList.count
        
        if (isSearchInProgress) {
            numOfItems = self.searchedBookList.count
        }
        
        return numOfItems
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! bookCollectionViewCell
    
        var booksToBeDisplayed = booksList
        
        if (isSearchInProgress && searchedBookList.count > 0) {
            booksToBeDisplayed = searchedBookList
        }
        
        cell.book = booksToBeDisplayed[indexPath.row]
        
        return cell
    }
}

// MARK: Collection view flow layout
extension booksCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15);
    }
}

// MARK: Searching Logic
extension booksCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate  {

    func updateSearchResults(for searchController: UISearchController) {
        services.fetchBooks(forSearchText: searchController.searchBar.text!) { (BooksDataSource) in
            self.searchedBookList = BooksDataSource.results
        }
        
        self.collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearchInProgress = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearchInProgress = false
        self.collectionView.reloadData()
    }
}

// MARK: Open the book in browser
extension booksCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let booksList = (isSearchInProgress && self.searchedBookList.count > 0 ) ? self.searchedBookList : self.booksList
        
        // Decide the format and open the browser. Display alert if no format is available.
        self.startReadingThe(book: booksList, at: indexPath)
    }
    
    private func startReadingThe(book: [Book], at indexPath: IndexPath) {
        // Process the format of the book.
        /* The supported formats are as follows:
            1. HTML
            2. PDF
            3. TXT
         */
        
        let bookFormats = book[indexPath.row].formats
        
        var format: String? = nil
        
        if let html = bookFormats["text/html; charset=utf-8"], !html.hasSuffix(".zip") {
            format = html
        }
        else if let html = bookFormats["text/html; charset=iso-8859-1"], !html.hasSuffix(".zip") {
            format = html
        }
        else if let pdf = bookFormats["application/pdf"], !pdf.hasSuffix(".zip") {
            format = pdf
        }
        else if let txt = bookFormats["text/plain; charset=utf-8"], !txt.hasSuffix(".zip") {
            format = txt
        }
        else if let txt = bookFormats["text/plain; charset=iso-8859-1"], !txt.hasSuffix(".zip") {
            format = txt
        }
        else if let txt = bookFormats["text/plain"], !txt.hasSuffix(".zip") {
            format = txt
        }
        
        if let formatToUse = format, let bookToOpen = URL(string: formatToUse) {
            if UIApplication.shared.canOpenURL(bookToOpen) {
                UIApplication.shared.open(bookToOpen, options: [:], completionHandler: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "Warning!", message: "The format specified is not supported yet.", preferredStyle: .alert)
            let button = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(button)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: Image Caching logic
fileprivate let bookImageCache = NSCache<NSString, UIImage>()

class CustomImageView: UIImageView {
    private var imageURLString: String?
    
    public func imageFromURL(URLString: String) {
        self.imageURLString = URLString
        image = nil
        
        if let cachedBookImage = bookImageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedBookImage
            
            return
        }
        
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.startAnimating()
        
        if self.image == nil {
            self.addSubview(loadingIndicator)
            
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        
        URLSession.shared.dataTask(with: NSURL(string: URLString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error ?? "No Error")
                
                return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                let imageToCache = UIImage(data: data!)
                
                if self.imageURLString == URLString {
                    loadingIndicator.removeFromSuperview()
                    self.image = imageToCache
                }
                
                bookImageCache.setObject(imageToCache!, forKey: NSString(string: URLString))
            })
        }).resume()
    }
}

