//
//  ServiceManager.swift
//  Book Library
//
//  Created by Kuldeep Kumar P on 04/12/20.
//  Copyright © 2020 Kuldeep Kumar P. All rights reserved.
//

import Foundation

enum Genre: String {
    case Fiction
    case Fantasy
    case Adventure
    case Romance
    case Contemporary
    case Dystopian
    case Mystery
    case Horror
    case Thriller
    case Paranormal
    case Historical_fiction
    case Science_Fiction
    case Memoir
    case Cooking
    case Art
    case SelfHelpOrPersonal
    case Development
    case Motivational
    case Health
    case History
    case Travel
    case GuideOrHow_To
    case FamiliesAndRelationships
    case Humor
    case Children
}

struct ServiceType {
    static let bookListBaseUrl = "http://skunkworks.ignitesol.com:8000/books/?mime_type=image%2Fjpeg"
    
    static func urlForGenre(_ genre: Genre) -> URL? {
        return URL(string: "\(self.bookListBaseUrl)&topic=\(genre.rawValue)")
    }
    
    static func urlForSearch(_ text: String) -> URL? {
        var string = "\(self.bookListBaseUrl)&search="
        if let encodedString = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            string += encodedString
        }
        
        return URL(string: string)
    }
}

class serviceManager {
    let session = URLSession.shared
    
    func fetchBooksFor(genre:Genre, with callback:((BooksDataSource) -> ())?) {
        if let url = ServiceType.urlForGenre(genre) {
            self.fetchBooks(using: url, with: callback)
        }
    }
    
    func fetchBooks(forSearchText text: String, with callback: ((BooksDataSource) -> ())?) {
        if let searchUrl = ServiceType.urlForSearch(text), text.count > 0 {
            self.fetchBooks(using: searchUrl, with: callback)
        }
    }
    
    private func fetchBooks(using url:URL, with callback:((BooksDataSource) -> ())?) {
        self.session.dataTask(with: url) { (data, response, error) in
            if let responseError = error {
                print("error ",responseError)
            }
            else if let recievedData = data {
                do {
                    let bookData = try JSONDecoder().decode(BooksDataSource.self, from: recievedData)
                    
                    callback?(bookData)
                }
                catch(let exception) {
                    print("error ",exception)
                }
                
            }
        }.resume()
    }
}

