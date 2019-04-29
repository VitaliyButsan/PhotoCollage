//
//  Router.swift
//  Netvit
//
//  Created by vit on 4/21/19.
//  Copyright © 2019 vit. All rights reserved.
//

import Foundation
import Alamofire

// router for choices requests
enum Router: URLRequestConvertible {
    
    // possible cases
    case getPhotos(onPage: Int, withLimit: Int)
    case searchPhotos(onPage: Int, viaName: String)

    // base url string
    static private let baseURL = "https://api.unsplash.com"
    
    // define http method to request
    private var method: HTTPMethod {
        switch self {
        case .getPhotos, .searchPhotos:
            return .get
        }
    }
    
    // assemble url path to request
    private var path: String {
        switch self {
        case .getPhotos(let page, let limit):
            return "/photos?page=\(page)&per_page=\(limit)&client_id=4c9fbfbbd92c17a2e95081cec370b4511659666240eb4db9416c40c641ee843b"
        case .searchPhotos(let page, let name):
            return "/search/photos?page=\(page)&query=\(name)&client_id=4c9fbfbbd92c17a2e95081cec370b4511659666240eb4db9416c40c641ee843b"
        }
        
    }
    
    // URLrequest formation (url + httpMethod)
    func asURLRequest() throws -> URLRequest {
        let url = try(Router.baseURL + path).asURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        print("<-- ", urlRequest)
        return urlRequest
    }
    
}
