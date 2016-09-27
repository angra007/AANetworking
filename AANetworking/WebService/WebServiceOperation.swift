//
//  WebServiceOperation.swift
//  WebService
//
//  Created by Ankit Angra on 22/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

final class WebServiceOperation : NSOperation {
    
    internal var operationType : OperationType? 
    private var postData : NSData?
    private var completionHandler : WebServiceCompletionHandler?
    private var processDownloadedData : ProcessDownloadCompletionHandler?
    private var methodType : RequestMethodType?
    private var contentType : RequestContentType?
    private var retryCount = 0
    private let maximunNumberOfRetry = 3
    class func instantiate () -> WebServiceOperation {
        return WebServiceOperation()
    }
}

extension WebServiceOperation {
    
    /**
        This the method which is main method responsible to download JSON from server. As this is in NSOperation class it adds itself to the 
        requestQueue. All the elements which are required to download are passed in Struct Resource. These elements are saved locally so that 
        they can be used later.
        @param resource : This is the download resource. This will contain all the information to fetch data.
        completion : This is the completion Handler which will be called once we have some data or a error
    */
    func loadJSON<A>(resource: Resource<A>, completion:WebServiceCompletionHandler) {
        operationType = resource.operationType
        postData = resource.data
        methodType = resource.methodType
        contentType = resource.contentType
        completionHandler = completion
        processDownloadedData = resource.parse
        WebServiceManager.sharedManager.addRequest (self)
    }
}

extension WebServiceOperation {
    internal override func main() {
        
        // If cancelled, return immediately informing the requester.
        if self.cancelled {
            informCompletion(withData: nil, error: nil)
            return
        }
        
        // URL Validation
        let urlString = self.operationType?.url
        guard !urlString!.isEmpty else {
            informCompletion(withData: nil, error: nil)
            return
        }
        let url = NSURL.init(string: urlString!)
    
        // If cancelled, return immediately informing the requester.
        if self.cancelled {
            informCompletion(withData: nil, error: nil)
            return
        }
        
        // This is to support GET and POST
        if (self.contentType == .URLEncoded || self.contentType == .JSON)  {
            let JSONRequest = JSONRequestor ()
            
            // Method responsible to retry the request
            func retry () {
                retryCount = retryCount + 1
                load()
            }
            
            func load () {
                JSONRequest.timeOut = 60 *  Double ((self.retryCount + 1))
                
                 // No Network Condition Here
                
                if self.methodType == .GET {
                    JSONRequest.getRequest(url!, completion: { (result, error,shouldRetry) in
                        
                        if shouldRetry == true && self.retryCount < (self.maximunNumberOfRetry - 1) {
                            retry()
                        }
                        else {
                            self.handleDownloadCompletion(result, error: error)
                        }
                        
                    })
                }
                else if self.methodType == .POST {
                    JSONRequest.postRequest(withData: postData!, url: url!, contentType: contentType!,completion:  { (result, error,shouldRetry) in
                        
                        if shouldRetry == true && self.retryCount < (self.maximunNumberOfRetry - 1) {
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
    
    func handleDownloadCompletion (result : JSONDictionary?, error : NSError?) {
       
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









