//
//  bookCollectionViewCell.swift
//  Book Library
//
//  Created by Kuldeep Kumar P on 04/12/20.
//  Copyright © 2020 Kuldeep Kumar P. All rights reserved.
//

import UIKit

class bookCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var bookImage: CustomImageView!
    
    var book: Book? {
        didSet {
            if let imageUrl = self.book?.formats["image/jpeg"] {
                self.bookImage?.imageFromURL(URLString: imageUrl)
            }
            
            self.bookName?.text = self.book?.title.uppercased()
        }
    }
}
