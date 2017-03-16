//
// WebRequestResources.swift
// https://github.com/angra007/AANetworking
// Copyright (c) 2013-16 Ankit Angra.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// All the request will be of this Resource type. This would act as a data structure for all the type of request's. Everything need to define a request will go inside this Resource
public struct Resource <A> {
    public let urlString : String
    public let methodType : RequestMethodType
    public let contentType : RequestContentType
    public let data : Data?
    public let multipartBoundry : String?
    public let parse : ProcessDownloadCompletionHandler
    
}

// MARK: - Initilizers are given in a extension so that we still have the default initilizer around if in case we need it.
extension Resource {
    
    ///   GET Request Initilizer
    ///
    /// - parameter operationType: Operation type of the request
    /// - parameter parse:
    ///
    /// - returns:
    public init (url : String, parse : @escaping ProcessDownloadCompletionHandler) {
        self.urlString = url
        self.methodType = .get
        self.contentType = .urlEncoded
        self.data = nil
        self.parse = parse
        self.multipartBoundry = nil
    }
    
    /// POST Request Initilizer
    ///
    /// - parameter operationType: Operation Type
    /// - parameter contentType:   Content type of the request
    /// - parameter postData:      Dara which has to be send to server
    /// - parameter parse:         Parseing Method
    ///
    /// - returns: initlized POST Request
    public init (url : String, contentType : RequestContentType, postData : Data, parse : @escaping ProcessDownloadCompletionHandler ) {
        self.urlString = url
        self.methodType = .post
        self.contentType = contentType
        self.data = postData
        self.parse = parse
        self.multipartBoundry = nil
    }
    
    /// POST Request Initilizer
    ///
    /// - parameter operationType: Operation Type
    /// - parameter url: URL of the Operation which cannot be defined in Operation Type
    /// - parameter contentType:   Content type of the request
    /// - parameter postData:      Dara which has to be send to server
    /// - parameter parse:         Parseing Method
    /// - parameter multipartBoundry: Boundry used to send multipart requests
    ///
    /// - returns: initlized POST Request
    public init (url : String, postData : Data, multipartBoundry : String , parse : @escaping ProcessDownloadCompletionHandler ) {
        self.urlString = url
        self.methodType = .post
        self.contentType = .multipart
        self.data = postData
        self.parse = parse
        self.multipartBoundry = multipartBoundry
    }
    
}
