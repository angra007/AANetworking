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
    private let webServiceManager = WebServiceManager ()
    private var urlString : String? = nil
    private var processDownloadedData : ProcessDownloadCompletionHandler? = nil
    private var request: NSMutableURLRequest?
    private var completionHandler : WebServiceCompletionHandler? = nil
    private var postData : NSData?
    private var requestType : RequestType?
    private var headerType : RequestHeaderFieldType?
    private var retryCount = 0
    private var loadRequestType : LoadRequestType = .None
    
    class func instantiate () -> WebServiceOperation {
        return WebServiceOperation()
    }
}

extension WebServiceOperation {
    func loadJSON<A>(resource: Resource<A>, completion:WebServiceCompletionHandler) {
        loadRequestType = .JSON
        operationType = resource.operationType
        urlString = resource.urlString
        postData = resource.data
        requestType = resource.requestType
        headerType = resource.headerType
        completionHandler = completion
        processDownloadedData = resource.parse
        webServiceManager.addRequest (self)
    }
}

extension WebServiceOperation {
    internal override func main() {
        
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
        
        if self.loadRequestType == .JSON {
            let JSONRequest = JSONRequestor ()
            JSONRequest.timeOut = 60 *  Double ((self.retryCount + 1))
            
            // No Network Condition
            
            if self.requestType == .GET {
                JSONRequest.getRequest(url!, completion: { (data, error,shouldRetry) in
                })
            }
            else if self.requestType == .POST {
                JSONRequest.postRequest(withData: postData!, url: url!, headerType: headerType!) { (data, error,shouldRetry) in
                }
            }
            else {
                
            }
        }
     }
    
    func informCompletion(withData data: AnyObject?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue() ) {
            (self.completionHandler? (data,error))!
        }
    }
}

extension WebServiceOperation {
    func retry() {
        retryCount = retryCount + 1
        webServiceManager.cancelOperationWithOperationType(self.operationType!)
        webServiceManager.addRequest(self)
    }
}








