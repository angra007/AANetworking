//
//  Constants.swift
//  WebService
//
//  Created by Ankit Angra on 22/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

let key : String = "4c989ba3813652e9f29d4dfd44bd34ad"

enum OperationType : String {
    case topRated = "topRatedMovies"
    
    var url : String {
        switch self {
        case .topRated:
            return "http://api.themoviedb.org/3/movie/top_rated?api_key=\(key)&&page=1"
        }
    }
}

enum CacheType : String {
    case Asserts = "AssetsCache"
}