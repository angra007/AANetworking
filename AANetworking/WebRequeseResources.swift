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
    let modificationDate : NSDate
    let saveInCache : ( (NSData) throws -> Any?)
}

class WebRequestResources {
  
    class func movieResource () -> Resource<[Any]> {
        let type : OperationType = .topRated
        let resource = Resource<[Any]>(urlString: type.url ,operationType : type, parse: { data in
            // Parse your model object here and return parsed object
            return data
        })
        return resource
    }
    
    class func imageResource (urlString url:String, modificationDate : NSDate) -> MediaResource<UIImage>  {
        let resource = MediaResource<UIImage>(urlString: url, modificationDate: modificationDate, saveInCache: { (data) -> Any? in
            // Save Image in Cache Here
            let cache = Cache (type :.Asserts)
            cache.store(data, forURL: url, timestamp: modificationDate)
            return data
        })
        return resource
    }
}