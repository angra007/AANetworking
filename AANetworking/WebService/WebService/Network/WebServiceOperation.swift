//
//  WebServiceOperation.swift
//  Wand
//
//  Created by Ankit Angra on 03/10/16.
//  Copyright © 2016 Pro Unlimited Inc. All rights reserved.
//

import Foundation

open class WebServiceOperation {

    var url : String?
    var postData : Data?
    var completionHandler : WebServiceCompletionHandler?
    var processDownloadedData : ProcessDownloadCompletionHandler?
    var methodType : RequestMethodType?
    var contentType : RequestContentType?
    
//    public init <A> (_ resource: Resource<A>) {
//        url = resource.urlString
//        postData = resource.data as Data?
//        methodType = resource.methodType
//        contentType = resource.contentType
//        processDownloadedData = resource.parse
//    }
//    
    
    public init() {}
    deinit {
        print ("WebServiceOperation dealloc called")
    }
}

extension WebServiceOperation {
    /// This the method which is main method responsible to download JSON from server. As this is in NSOperation class it adds itself to the requestQueue. All the elements which are required to download are passed in Struct Resource. These elements are saved locally so that they can be used later
    ///
    /// - parameter resource:   This is the download resource. This will contain all the information to fetch data.
    /// - parameter completion: This is the completion Handler which will be called once we have some data or a error
    public func loadJSON<A>(_ resource: Resource<A>, completion:@escaping WebServiceCompletionHandler) {
        url = resource.urlString
        postData = resource.data as Data?
        methodType = resource.methodType
        contentType = resource.contentType
        completionHandler = completion
        processDownloadedData = resource.parse
        load()
    }
}

extension WebServiceOperation {
    
    func load () {

        // URL Validation
        let urlString = self.url
        guard !urlString!.isEmpty else {
            informCompletion(withData: nil, error: nil, log : "",status: "")
            return
        }
        let url = URL.init(string: urlString!)
        
        // This is to support GET and POST
        if (self.contentType == .urlEncoded || self.contentType == .json)  {
            let JSONRequest  : WebRequest! = JSONRequestor ()
            if self.methodType == .get {
                JSONRequest.getRequest(url!, completion: {  (result, error,log) in
                    self.handleDownloadCompletion(result, error: error,log: log)
                })
            }
            else if self.methodType == .post {
                JSONRequest.postRequest(withData: postData!, url: url!, contentType: contentType!,completion:  { (result, error,log) in
                    self.handleDownloadCompletion(result, error: error,log: log)
                })
            }
        }
    }
    
    func handleDownloadCompletion (_ result : JSONDictionary?, error : NSError?,log : NSString) {
        var object : AnyObject? = nil
        var currentStatus : String? = nil
        
        
        if let result = result {
            guard let results : [String:AnyObject] = result["data"] as? [String:AnyObject] else {  return }
            
            if let status = results["status"] {
                currentStatus = String (describing: status)
            }
            
            object = self.processDownloadedData?(result)
        }

        self.informCompletion(withData: object, error: error,log: log, status: currentStatus)
    }
    
    func informCompletion(withData result: AnyObject?, error: NSError?, log : NSString, status : String?) {
        DispatchQueue.main.async {  
            self.completionHandler? (result,error,log,status)
//            self.contentType = nil
//            self.methodType = nil
//            self.processDownloadedData = nil
//            self.completionHandler = nil
//            self.postData = nil
//            self.url = nil
        }
    }
}
