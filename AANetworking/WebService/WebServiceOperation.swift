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
            
            func retry () {
                retryCount = retryCount + 1
                load()
            }
            
            func load () {
                JSONRequest.timeOut = 60 *  Double ((self.retryCount + 1))
                
                 // No Network Condition Here
                
                if self.requestType == .GET {
                    JSONRequest.getRequest(url!, completion: { (result, error,shouldRetry) in
                        
                        if shouldRetry == true && self.retryCount < 2 {
                            retry()
                        }
                        else {
                            self.handleDownloadCompletion(result, error: error)
                        }
                        
                    })
                }
                else if self.requestType == .POST {
                    JSONRequest.postRequest(withData: postData!, url: url!, headerType: headerType!,completion:  { (result, error,shouldRetry) in
                        
                        if shouldRetry == true && self.retryCount < 2 {
                            retry()
                        }
                        else {
                            self.handleDownloadCompletion(result, error: error)
                        }
                    })
                }
            }
            
            load()
        }
     }
    
    func informCompletion(withData result: AnyObject?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue() ) {
            (self.completionHandler? (result,error))!
        }
    }
    
    func handleDownloadCompletion (result : AnyObject?, error : NSError?) {
       
        if error != nil {
            // Send the log here
            if error!.code != -97 {
                self.informCompletion(withData: nil, error: error!)
                return
            }
        }
        
        if result != nil {
            // Fill Model
            let object = self.processDownloadedData?(result!)
            
            // Pass the model object back
            self.informCompletion(withData: object, error: nil)
        }
    }
}









