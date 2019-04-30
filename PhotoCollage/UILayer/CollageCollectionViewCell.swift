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
    
    var delegate: CollageCollectionViewController?

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
        delegate?.performZoomForImageView(imageView)
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
