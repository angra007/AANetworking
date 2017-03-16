//
//  NetworkHelper.swift
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
import WebService

class NetworkHelper {
    
    var complitionHandler : ((AnyObject?, NSError?) -> Void)? = nil
    
    class func load (url : String, parse : @escaping ProcessDownloadCompletionHandler, completion : @escaping ((AnyObject?, NSError?) -> Void) ) {
        let resource = Resource<Any> (url : url, parse: parse)
        NetworkHelper.sendRequest(resource,completion: completion)
    }
    
    class func load(url : String, contentType : RequestContentType,data : Data, parse : @escaping ProcessDownloadCompletionHandler, completion : @escaping ((AnyObject?, NSError?) -> Void) ) {
        let resource = Resource<Any> (url : url, contentType: contentType, postData: data, parse: parse)
        NetworkHelper.sendRequest(resource,completion: completion)
    }
    
    class func load (url : String, data : Data,multipartBoundry : String, parse : @escaping ProcessDownloadCompletionHandler, completion : @escaping ((AnyObject?, NSError?) -> Void) ) {
        let resource = Resource<Any> (url : url, postData: data, multipartBoundry: multipartBoundry, parse: parse)
        NetworkHelper.sendRequest(resource,completion: completion)
    }
    
    class func sendRequest <A>(_ resource: Resource<A>, completion:@escaping ((AnyObject?, NSError?) -> Void)) {
        WebServiceOperation.instantiate().loadJSON(resource) { (data, error, log,currentStatus) in
            completion (data, error)
        }
    }
    
    class func cancelRequest (forUrl url: String) {
        
        WebServiceManager.sharedManager.removeTaskFromQueue(withUrl: url)
        
    }
    
    class func cancelAllRequest () {
        WebServiceManager.sharedManager.cancelAllRequests()
    }
    
}