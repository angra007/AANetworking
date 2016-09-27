//
//  WebRequeseResources.swift
//  AANetworking
//
//  Created by Ankit Angra on 23/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

// All the request will be of this Resource type. This would act as a data structure for all the type of request's. 
// Everything need to define a request will go inside this Resource
struct Resource <A> {
    let urlString : String
    let operationType : OperationType
    let methodType : RequestMethodType
    let contentType : RequestContentType
    let data : NSData?
    let parse : ProcessDownloadCompletionHandler
}

// Initilizers are given in a extension so that we still have the default initilizer around if in case we need it.
extension Resource {
    
    // GET Request Initilizer
    init (operationType : OperationType, parse : ProcessDownloadCompletionHandler) {
        self.urlString = operationType.url
        self.operationType = operationType
        self.methodType = .GET
        self.contentType = .URLEncoded
        self.data = nil
        self.parse = parse
    }
    
    // POST Request Initilizer
    init (operationType : OperationType, contentType : RequestContentType, postData : NSData, parse : ProcessDownloadCompletionHandler ) {
        self.urlString = operationType.url
        self.operationType = operationType
        self.methodType = .POST
        self.contentType = contentType
        self.data = postData
        self.parse = parse
    }
}





