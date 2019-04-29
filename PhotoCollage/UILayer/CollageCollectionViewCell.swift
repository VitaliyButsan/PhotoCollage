//
//  CollageCollectionViewCell.swift
//  PhotoCollage
//
//  Created by vit on 4/23/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import SDWebImage

// collection view cell on main window
class CollageCollectionViewCell: UICollectionViewCell {
    
    var zoomDelegator: CollageTableViewController?

    // set image view and add gesture to it
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    // handler tap to zoom
    @objc private func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        guard let imageView = tapGesture.view as? UIImageView else { return }
        zoomDelegator?.performZoomForImageView(imageView)
    }
    
    // layout collectionViewCell subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.addSubview(photoImageView)
        photoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        photoImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        photoImageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        photoImageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
    
    // update collectionViewCell with new data
    func updateCollectionViewCell(withUrl url: URL) {
        photoImageView.sd_setImage(with: url, completed: nil)
    }
    
}
