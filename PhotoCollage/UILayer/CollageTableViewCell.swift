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
    private var triplePhotoUrl = [URL]()
    
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
        flowLayout.minimumInteritemSpacing = UIDevice.current.modelName == "iPhone 5" ? 5 : -5
        let imageHeight: CGFloat = UIDevice.current.modelName == "iPhone 5" ? 120 : 150
        let imageWidth: CGFloat = (collectionView.frame.width - flowLayout.minimumInteritemSpacing * 2) / 3
        flowLayout.itemSize = CGSize(width: imageWidth, height: imageHeight)
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
        cell.zoomDelegator = zoomDelegateBrige
        return cell
    }
   
}

// determine used device
public extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPhone5,1", "iPhone5,2", "iPhone5,3", "iPhone5,4", "iPhone6,1", "iPhone6,2", "iPhone8,4":
            return "iPhone 5"
            
        case "iPhone7,2", "iPhone8,1", "iPhone9,1", "iPhone9,3", "iPhone10,1", "iPhone10,4":
            return "iPhone 6,7,8"
            
        case "iPhone7,1", "iPhone8,2", "iPhone9,2", "iPhone9,4", "iPhone10,2", "iPhone10,5":
            return "iPhone Plus"
            
        case "iPhone10,3", "iPhone10,6":
            return "iPhone X"
            
        default:
            return identifier
        }
    }
}
