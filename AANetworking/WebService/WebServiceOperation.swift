//
//  WebServiceOperation.swift
//  WebService
//
//  Created by Ankit Angra on 22/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

final class WebServiceOperation : NSOperation {
    
    internal var operationType : OperationType? = nil
    let webServiceManager = WebServiceManager ()
    private var urlString : String? = nil
    private var processDownloadedData : ProcessDownloadCompletionHandler? = nil
    private var request: NSMutableURLRequest?
    private var completionHandler : WebRequestCompletionHandler? = nil
    private var postData : NSData?
    private var type : RequestType?
    private var headerType : RequestHeaderFieldType?
    
    class func instantiate () -> WebServiceOperation {
        return WebServiceOperation()
    }
    
    internal func load<A>(resource: Resource<A>, completion:WebRequestCompletionHandler) {
        operationType = resource.operationType
        urlString = resource.urlString
        postData = resource.data
        type = resource.requestType
        headerType = resource.headerType
        completionHandler = completion
        processDownloadedData = resource.parse
        webServiceManager.addRequest (self)
    }
    
    internal func loadMedia <A> (resource : MediaResource<A>, completion:WebRequestCompletionHandler) {
        
        let cache = Cache (type :.Asserts)
        if let data = cache.data(forURL: resource.urlString, timestamp: resource.modificationDate) {
            dispatch_async(dispatch_get_main_queue() ) {
                self.completionHandler? (data,nil)
            }
        }
        else {
            urlString = resource.urlString
            completionHandler = completion
            processDownloadedData = resource.saveInCache
            webServiceManager.addRequest(self)
        }
    }
}

extension WebServiceOperation {
    internal override func main() {
        func informCompletion(withData data: AnyObject?, error: NSError?) {
            dispatch_async(dispatch_get_main_queue() ) {
                (self.completionHandler? (data,error))!
            }
        }
        
        if self.cancelled {
            informCompletion(withData: nil, error: nil)
            return
        }
        
        let urlString = self.urlString
        guard !urlString!.isEmpty else {
            informCompletion(withData: nil, error: nil)
            return
        }
        
        let url = NSURL.init(string: urlString!)
        self.request = NSMutableURLRequest.init(URL: url!)
    
        // If cancelled, return immediately informing the requester.
        if self.cancelled {
            informCompletion(withData: nil, error: nil)
            return
        }
        
        if self.type == .GET {
            WebRequest.instantiate().getRequest(url!, completion: { (data, error) in
                if error != nil {
                    informCompletion(withData: nil, error: error)
                }
                else
                {
                    let result =  self.processDownloadedData!(data!)
                    // 500,501,1000
                    informCompletion(withData: result, error: nil)
                }
            })
        }
        else {
            WebRequest.instantiate().postRequest(withData: postData!, url: url!, headerType: headerType!) { (data, error) in
                
                if error != nil {
                    informCompletion(withData: nil, error: error)
                }
                else
                {
                    let result =  self.processDownloadedData!(data!)
                    // 500,501,1000
                    informCompletion(withData: result, error: nil)
                }
            }
        }
    }
}







