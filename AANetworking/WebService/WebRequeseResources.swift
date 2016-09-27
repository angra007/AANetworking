//
//  WebRequeseResources.swift
//  AANetworking
//
//  Created by Ankit Angra on 23/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation
import UIKit


typealias WebRequestCompletionHandler = ((AnyObject?, NSError?) -> Void)
typealias ProcessDownloadCompletionHandler = ((NSData) throws -> AnyObject?)


struct Resource <A> {
    let urlString : String
    let operationType : OperationType
    let requestType : RequestType
    let headerType : RequestHeaderFieldType
    let data : NSData?
    let parse : ProcessDownloadCompletionHandler
}

extension Resource {
    
    // GET Request Initilizer
    init (urlString : String, operationType : OperationType, parse : ( (NSData)  -> AnyObject?)) {
        self.urlString = urlString
        self.operationType = operationType
        self.requestType = .GET
        self.headerType = .None
        self.data = nil
        self.parse = parse
    }
    
    // POST Request Initilizer
    init (urlString : String, operationType : OperationType, headerType : RequestHeaderFieldType, postData : NSData, parse : ( (NSData) -> AnyObject?) ) {
        self.urlString = urlString
        self.operationType = operationType
        self.requestType = .POST
        self.headerType = headerType
        self.data = postData
        self.parse = parse
    }
}

struct MediaResource <A> {
    let urlString : String
    let modificationDate : NSDate
    let saveInCache : ( (NSData) -> AnyObject?)
}




