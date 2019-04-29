//
//  Networking.swift
//  Netvit
//
//  Created by vit on 4/21/19.
//  Copyright © 2019 vit. All rights reserved.
//

import Foundation
import Alamofire

// Networking class
public class Netvit {
    
    // define getPhotos func
    public static func getPhotos(onPage page: Int, withLimit limit: Int, completionHandler: @escaping (Result<[PhotoDetails]>) -> Void) {
        Alamofire.request(Router.getPhotos(onPage: page, withLimit: limit)).responseJSON { response in
            guard let data = response.data else { return }
            
            do {
                let receivedData = try JSONDecoder().decode([PhotoDetails].self, from: data)
                completionHandler(.success(receivedData))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    // define searchPotos func 
    public static func searchPhotos(onPage page: Int, viaName name: String, completionHandler: @escaping (Result<SearchingPhotosWrapper>) -> Void) {
        Alamofire.request(Router.searchPhotos(onPage: page, viaName: name)).responseJSON { response in
            guard let data = response.data else { return }
            
            do {
                let receivedData = try JSONDecoder().decode(SearchingPhotosWrapper.self, from: data)
                completionHandler(.success(receivedData))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
    
    
}
