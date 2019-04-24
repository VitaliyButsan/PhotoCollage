//
//  CollageTableViewCell.swift
//  PhotoCollage
//
//  Created by vit on 4/23/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit

class CollageTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    var triplePhotoUrl = [URL]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // set flowLayout
        setFlowLayout()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        //flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 120, height: 150)
        flowLayout.minimumLineSpacing = 10.0
        self.collectionView.collectionViewLayout = flowLayout
    }
   
    func updateCell(withTriplePhoto triple: [URL]) {
        triplePhotoUrl = triple
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    

    // MARK: UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return triplePhotoUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollageCollectionViewCell
        cell.updateCollectionViewCell(withUrl: triplePhotoUrl[indexPath.row])
        return cell
    }
   
}
