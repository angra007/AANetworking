//
//  WebServiceOperation.swift
//  WebService
//
//  Created by Ankit Angra on 22/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

typealias WebRequestCompletionHandler = ((Any?, NSError?) -> Void)

final class WebServiceOperation : NSOperation {
    
    internal var operationType : OperationType? = nil
    private var urlString : String? = nil
    private var processDownloadedData : ( (NSData) throws -> Any?)? = nil
    private var request: NSMutableURLRequest?
    private var completionHandler : WebRequestCompletionHandler? = nil
    let webServiceManager = WebServiceManager ()
    
    class func instantiate () -> WebServiceOperation {
        return WebServiceOperation()
    }
    
    internal func load<A>(resource: Resource<A>, completion:WebRequestCompletionHandler) {
        operationType = resource.operationType
        urlString = resource.urlString
        completionHandler = completion
        processDownloadedData = resource.parse
        webServiceManager.addRequest(self)
    }
    
    internal func loadMedia <A> (resource : MediaResource<A>, completion:WebRequestCompletionHandler) {
        urlString = resource.urlString
        completionHandler = completion
        processDownloadedData = resource.saveInCache
        webServiceManager.addRequest(self)
    }
}

extension WebServiceOperation {
    internal override func main() {
        func informCompletion(withData data: Any?, error: NSError?) {
            dispatch_async(dispatch_get_main_queue() ) {
                self.completionHandler? (data,error)
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
        
        NSURLSession.sharedSession().dataTaskWithRequest(self.request!) { (data, response, error) in
            if error != nil {
                informCompletion(withData: nil, error: error)
                return
            }
            
            // If cancelled, return immediately informing the requester.
            if self.cancelled {
                informCompletion(withData: nil, error: nil)
                return
            }
            
            if data == nil {
                informCompletion(withData: nil, error: nil)
                return
            }
            
            do {
                // Try parsing the data
                let result = try self.processDownloadedData!(data!)
                // Return the result to the caller
                informCompletion(withData: result, error: nil)
            } catch let parseError as NSError {
                informCompletion(withData: nil, error: parseError)
            } catch {
                // TODO: Prepare a specific error and return
                informCompletion(withData: nil, error: nil)
            }

        }.resume()
        
    }
}
