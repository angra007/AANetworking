//
//  WebRequeseResources.swift
//  AANetworking
//
//  Created by Ankit Angra on 23/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

/// All the request will be of this Resource type. This would act as a data structure for all the type of request's. Everything need to define a request will go inside this Resource
struct Resource <A> {
    let urlString : String
    let operationType : OperationType
    let methodType : RequestMethodType
    let contentType : RequestContentType
    let data : Data?
    let parse : ProcessDownloadCompletionHandler
}

// MARK: - Initilizers are given in a extension so that we still have the default initilizer around if in case we need it.
extension Resource {
    
    ///   GET Request Initilizer
    ///
    /// - parameter operationType: Operation type of the request
    /// - parameter parse:
    ///
    /// - returns:
    init (operationType : OperationType, parse : @escaping ProcessDownloadCompletionHandler) {
        self.urlString = operationType.url
        self.operationType = operationType
        self.methodType = .get
        self.contentType = .urlEncoded
        self.data = nil
        self.parse = parse
    }
    
    /// POST Request Initilizer
    ///
    /// - parameter operationType: Operation Type
    /// - parameter contentType:   Content type of the request
    /// - parameter postData:      Dara which has to be send to server
    /// - parameter parse:         Parseing Method
    ///
    /// - returns: initlized POST Request
    init (operationType : OperationType, contentType : RequestContentType, postData : Data, parse : @escaping ProcessDownloadCompletionHandler ) {
        self.urlString = operationType.url
        self.operationType = operationType
        self.methodType = .post
        self.contentType = contentType
        self.data = postData
        self.parse = parse
    }
}





