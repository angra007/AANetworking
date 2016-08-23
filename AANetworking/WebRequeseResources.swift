//
//  WebRequeseResources.swift
//  AANetworking
//
//  Created by Ankit Angra on 23/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation


class WebRequestResources {
  
    
    static let sharedRequestResource = WebRequestResources()
    
    internal let episodesResource = Resource<[Movie]>(urlString: "http://api.themoviedb.org/3/movie/top_rated?api_key=4c989ba3813652e9f29d4dfd44bd34ad&&page=1",operationType : .listingDetails, parse: { data in
        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
        guard let dictionaries = json as? [String:AnyObject] else { return nil }
        guard let results : [AnyObject] = dictionaries["results"] as? [AnyObject] else {return nil }
        let abc = results.flatMap() {
            Movie.init(movieDetails: $0 as! JSONDictionary)
        }
        return abc;
    })
    
    
}