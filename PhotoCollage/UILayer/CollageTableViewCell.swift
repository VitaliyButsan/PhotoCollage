//
//  CollageTableViewCell.swift
//  PhotoCollage
//
//  Created by vit on 4/23/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit

// main application window class
class CollageTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    var zoomDelegateBrige: CollageTableViewController?
    
    // storage photo URL's
    var triplePhotoUrl = [URL]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // set flowLayout
        setFlowLayout()
        // set delegate, dataSource
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // difine set flow layout
    private func setFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 120, height: 150)
        flowLayout.minimumLineSpacing = 10.0
        self.collectionView.collectionViewLayout = flowLayout
    }
   
    // update cell with new data
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
    
    // reuse cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollageCollectionViewCell
        cell.updateCollectionViewCell(withUrl: triplePhotoUrl[indexPath.row])
        // redirect zoom handler
        cell.zoomDelegate = zoomDelegateBrige
        return cell
    }
   
}
