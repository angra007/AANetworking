//
//  WebRequeseResources.swift
//  AANetworking
//
//  Created by Ankit Angra on 23/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation
import UIKit

typealias JSONDictionary = [String : AnyObject]

struct Resource <A> {
    let urlString : String
    let operationType : OperationType
    let parse : ( (NSData) throws -> Any?)
}

struct MediaResource <A> {
    let urlString : String
    let trackingID : String
    let modificationDate : NSDate
    let saveInCache : ( (NSData) throws -> Any?)
}

class WebRequestResources {
  
    class func movieResource () -> Resource<[Movie]> {
        let type : OperationType = .topRated
        let resource = Resource<[Movie]>(urlString: type.url ,operationType : type, parse: { data in
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            guard let dictionaries = json as? [String:AnyObject] else { return nil }
            guard let results : [AnyObject] = dictionaries["results"] as? [AnyObject] else { return nil }
            return results.flatMap() {
                Movie.init(movieDetails: $0 as! JSONDictionary)
            }
        })
        return resource
    }
    
    class func imageResource (urlString url:String,trackingID : String, modificationDate : NSDate) -> MediaResource<UIImage>  {
        let resource = MediaResource<UIImage>(urlString: url, trackingID: trackingID, modificationDate: modificationDate, saveInCache: { (data) -> Any? in
            // Save Image in Cache Here
            return UIImage (data: data)
        })
        return resource
    }
}