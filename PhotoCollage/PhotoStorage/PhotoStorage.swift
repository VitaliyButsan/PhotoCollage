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
    
    var storagePhoto: [PhotoDetails] = []
    var searchingPhotoStorage: [PhotoDetails] = []
    
    func clearStoragePhoto() {
        storagePhoto.removeAll()
    }
    
    func clearSearchingPhoto() {
        searchingPhotoStorage.removeAll()
    }
}
