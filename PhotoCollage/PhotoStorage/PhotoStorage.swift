//
//  PhotoStorage.swift
//  PhotoCollage
//
//  Created by vit on 4/22/19.
//  Copyright © 2019 vit. All rights reserved.
//

import Foundation
import Netvit

class PhotoStorage {
    
    // storage arrays for received data
    var storagePhoto: [PhotoDetails] = []
    var searchingPhotoStorage: [PhotoDetails] = []
    
    // delete all received photo
    func clearStoragePhoto() {
        storagePhoto.removeAll()
    }
    
    // delete all founded photos
    func clearSearchingPhoto() {
        searchingPhotoStorage.removeAll()
    }
    
    // remove three elements from storage
    func removeTriplet(atIndex currentRow: Int) {
        let currentIndex = currentRow * 3
        
        if currentRow < storagePhoto.count {
            storagePhoto.removeSubrange(currentIndex ..< currentIndex + 3)
        }
    }
}
