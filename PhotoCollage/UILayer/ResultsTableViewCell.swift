//
//  ResultsTableViewCell.swift
//  PhotoCollage
//
//  Created by vit on 4/24/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import SDWebImage

// cell searching result
class ResultsTableViewCell: UITableViewCell {
    
    var resultsTableController: ResultsTableController?
    
    // custom image view
    lazy var photoImageView: UIImageView = {
        var imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    // handler tap to zoom
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        guard let imageView = tapGesture.view as? UIImageView else { return }
        resultsTableController?.performZoomForImageView(imageView)
    }
    
    // set layout for subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(photoImageView)
        photoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        photoImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        photoImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        photoImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
     }
    
    // update cell with new data
    func updateCell(withPhtoURL photoURL: URL) {
        self.photoImageView.sd_setImage(with: photoURL, completed: nil)
    }

}
