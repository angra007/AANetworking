//
//  NetworkHelper.swift
//  Wand
//
//  Created by Ankit on 03/02/17.
//  Copyright © 2017 Pro Unlimited Inc. All rights reserved.
//

import Foundation
import WebService

class NetworkHelper {
    
    
    class func load (url : String, parse : @escaping ProcessDownloadCompletionHandler, completion : @escaping ((AnyObject?, NSError?,String?) -> Void) ) {
        let resource = Resource<Any> (url : url, parse: parse)
        NetworkHelper.sendRequest(resource,completion: completion)
    }
    
    class func load(url : String, contentType : RequestContentType,data : Data, parse : @escaping ProcessDownloadCompletionHandler, completion : @escaping ((AnyObject?, NSError?,String?) -> Void) ) {
        let resource = Resource<Any> (url : url, contentType: contentType, postData: data, parse: parse)
        NetworkHelper.sendRequest(resource,completion: completion)
    }
    
    class func load (url : String, data : Data,multipartBoundry : String, parse : @escaping ProcessDownloadCompletionHandler, completion : @escaping ((AnyObject?, NSError?,String?) -> Void) ) {
        let resource = Resource<Any> (url : url, postData: data, multipartBoundry: multipartBoundry, parse: parse)
        NetworkHelper.sendRequest(resource,completion: completion)
    }
    
    class func sendRequest <A>(_ resource: Resource<A>, completion:@escaping ((AnyObject?, NSError?,String?) -> Void)) {
       
        let webServce : WebServiceOperation! = WebServiceOperation ()
        webServce.loadJSON(resource) { (data, error, log,currentStatus) in
            
        }
    }

    
    class func cancelRequest (forUrl url: String) {
    
        WebServiceManager.sharedManager.removeTaskFromQueue(withUrl: url)
    
    }

    class func cancelAllRequest () {
        WebServiceManager.sharedManager.cancelAllRequests()
    }
    
}
