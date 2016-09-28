//
//  WebServiceOperation.swift
//  WebService
//
//  Created by Ankit Angra on 22/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

final class WebServiceOperation : Operation {
    internal var operationType : OperationType?
    fileprivate var postData : Data?
    fileprivate var completionHandler : WebServiceCompletionHandler?
    fileprivate var processDownloadedData : ProcessDownloadCompletionHandler?
    fileprivate var methodType : RequestMethodType?
    fileprivate var contentType : RequestContentType?
}

extension WebServiceOperation {
    /// This the method which is main method responsible to download JSON from server. As this is in NSOperation class it adds itself to the requestQueue. All the elements which are required to download are passed in Struct Resource. These elements are saved locally so that they can be used later
    ///
    /// - parameter resource:   This is the download resource. This will contain all the information to fetch data.
    /// - parameter completion: This is the completion Handler which will be called once we have some data or a error
    func loadJSON<A>(_ resource: Resource<A>, completion:@escaping WebServiceCompletionHandler) {
        operationType = resource.operationType
        postData = resource.data as Data?
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
        if self.isCancelled {
            informCompletion(withData: nil, error: nil)
            return
        }
        
        // URL Validation
        let urlString = self.operationType?.url
        guard !urlString!.isEmpty else {
            informCompletion(withData: nil, error: nil)
            return
        }
        let url = URL.init(string: urlString!)
    
        // If cancelled, return immediately informing the requester.
        if self.isCancelled {
            informCompletion(withData: nil, error: nil)
            return
        }
        
        // This is to support GET and POST
        if (self.contentType == .urlEncoded || self.contentType == .json)  {
            let JSONRequest  : WebRequest! = JSONRequestor ()
            if self.methodType == .get {
                JSONRequest.getRequest(url!, completion: { (result, error) in
                    self.handleDownloadCompletion(result, error: error)
                })
            }
            else if self.methodType == .post {
                JSONRequest.postRequest(withData: postData!, url: url!, contentType: contentType!,completion:  { [unowned self](result, error) in
                    self.handleDownloadCompletion(result, error: error)
                })
            }
        }
     }
    
    func informCompletion(withData result: AnyObject?, error: NSError?) {
        DispatchQueue.main.async {
            self.completionHandler? (result,error)
        }
    }
    
    func handleDownloadCompletion (_ result : JSONDictionary?, error : NSError?) {
        var object : AnyObject? = nil
        if let result = result {
             object = self.processDownloadedData?(result)
        }
        self.informCompletion(withData: object, error: error)
    }
}









