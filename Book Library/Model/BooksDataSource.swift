//
//  BooksDataSource.swift
//  Book Library
//
//  Created by Kuldeep Kumar P on 04/12/20.
//  Copyright © 2020 Kuldeep Kumar P. All rights reserved.
//


import Foundation

// MARK: Master Datasource - Provides us with list of available books
struct BooksDataSource: Codable {
    var count: Int
    var nextPage: String?
    var previousPage: String?
    var results: [Book]
}

// MARK: Details of a Book - Provides us with details of a selected book
struct Book: Codable {
    var id: Int
    var title: String
    var authors: [Author]
    var subjects: [String]
    var bookshelves: [String]
    var languages: [String]
    var media_type: String
    var formats: [String: String]
    var download_count: Int
}

// MARK: Details of the Author - Provides us with details of the Author
struct Author: Codable {
    var name: String
    var birthYear: Int?
    var deathYear: Int?
}
