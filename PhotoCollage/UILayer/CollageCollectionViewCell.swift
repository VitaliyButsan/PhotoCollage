//
//  CollageCollectionViewCell.swift
//  PhotoCollage
//
//  Created by vit on 4/23/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import SDWebImage

class CollageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collageImageView: UIImageView!
    
    // update collection cell with new data
    func updateCollectionViewCell(withUrl url: URL) {
        collageImageView.sd_setImage(with: url, completed: nil)
    }
    
}
