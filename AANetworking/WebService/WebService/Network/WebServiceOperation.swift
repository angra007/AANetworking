//
// WebServiceOperation.swift
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

open class WebServiceOperation {
    var url : String?
    var postData : Data?
    var completionHandler : WebServiceCompletionHandler?
    var processDownloadedData : ProcessDownloadCompletionHandler?
    var methodType : RequestMethodType?
    var contentType : RequestContentType?
}

extension WebServiceOperation {
    /// This the method which is main method responsible to download JSON from server. As this is in NSOperation class it adds itself to the requestQueue. All the elements which are required to download are passed in Struct Resource. These elements are saved locally so that they can be used later
    ///
    /// - parameter resource:   This is the download resource. This will contain all the information to fetch data.
    /// - parameter completion: This is the completion Handler which will be called once we have some data or a error
    public func loadJSON<A>(_ resource: Resource<A>, completion:@escaping WebServiceCompletionHandler) {
        
        
        if isInternetActive () == true {
            url = resource.urlString
            postData = resource.data as Data?
            methodType = resource.methodType
            contentType = resource.contentType
            completionHandler = completion
            processDownloadedData = resource.parse
            load()
        }
        else {
            let noInternetError =  NSError (domain: "JSONError",code: -1000,userInfo: [NSLocalizedDescriptionKey: "Internet seems to be offline"])
            self.informCompletion(withData: nil, error: noInternetError, log: "", status: nil)
        }
        
    }
    
    func isInternetActive () -> Bool {
        
        var reachable = true
        let internetStatus = Reachability.forInternetConnection().currentReachabilityStatus ()
        if internetStatus == NotReachable {
            reachable = false
        }
        return reachable
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
        }
    }
}
