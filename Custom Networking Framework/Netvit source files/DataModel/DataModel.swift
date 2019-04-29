//
//  DataModel.swift
//  Netvit
//
//  Created by vit on 4/21/19.
//  Copyright © 2019 vit. All rights reserved.
//

import Foundation

// model for decoding
public struct SearchingPhotosWrapper: Decodable {
    public let results: [PhotoDetails]
}

public struct PhotoDetails: Decodable {
    public let urls: PhotoLink
    public let alt_description: String?
}

public struct PhotoLink: Decodable {
    public let small: URL
}
