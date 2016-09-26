//
//  WebRequest.swift
//  AANetworking
//
//  Created by Ankit Angra on 26/09/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation


class WebRequest {
    
    var multipartBoundary : String!
    private var request : NSMutableURLRequest?
    private var timeOut = 60.0
    private var errorLogString = NSMutableString ()
    private var startDate : NSDate!
    private var completionHandler : ((NSData?, NSError?) -> Void)?
    
    class func instantiate () -> WebRequest {
        return WebRequest()
    }
    
    private func sendRequest () {
        startDate = NSDate()
        NSURLSession.sharedSession().dataTaskWithRequest(self.request!) { (data, response, error) in
            if error != nil {
                self.informCompletion(withData: nil, error: error)
                return
            }
            
            if data == nil {
                self.informCompletion(withData: nil, error: nil)
                return
            }
            
            self.informCompletion(withData: data!, error: nil)
            
            }.resume()
    }
    
    
    func postRequest (withData data: NSData, url : NSURL, headerType :RequestHeaderFieldType, completion:((NSData?, NSError?) -> Void)) {
        
        let sessionID = ""
        //let privateKey = "lmnop"
        completionHandler = completion
        request =  NSMutableURLRequest.init(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
        request?.HTTPMethod = "POST"
        request?.setValue(String(data.length), forHTTPHeaderField: "Content-Length")
        var headerContentType : String
        switch  headerType {
        case .ApplicationURLEncoded :
            headerContentType = "application/x-www-form-urlencoded"
        case .ApplicationJSON :
            headerContentType = "application/json"
        case .ApplicationMultipart:
             headerContentType = "multipart/form-data; boundary=" + multipartBoundary
        default:
            headerContentType = "application/x-www-form-urlencoded"
        }
        request?.setValue(headerContentType, forHTTPHeaderField: "Content-Type")
        request?.HTTPBody = data
        
        
        errorLogString.appendString ("*******************\n")
        errorLogString.appendString("Request Type: POST \n")
        errorLogString.appendString("Url: \(String(url))\n")
        errorLogString.appendString("Cookie: \(String(sessionID)) \n")
        errorLogString.appendString("Body: \(String(data: data,encoding: NSUTF8StringEncoding))")
        errorLogString.appendString ("*******************\n")
        print(errorLogString)
        
        sendRequest()
    }
    
    func getRequest (url : NSURL, completion:((NSData?, NSError?) -> Void)) {
        let sessionID = ""
        completionHandler = completion
        request =  NSMutableURLRequest.init(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
        request?.HTTPMethod = "GET"
        let headerContentType = "application/x-www-form-urlencoded"
        request?.setValue(headerContentType, forHTTPHeaderField: "Content-Type")
        request?.setValue(sessionID, forHTTPHeaderField: "Cookie")
        
        errorLogString.appendString ("*******************\n")
        errorLogString.appendString("Request Type: GET \n")
        errorLogString.appendString("Url: \(String(url))\n")
        errorLogString.appendString("Cookie: \(String(sessionID)) \n")
        errorLogString.appendString ("*******************\n")
        print(errorLogString)
        
        sendRequest()
    }
}

extension WebRequest {
    func informCompletion(withData data: NSData?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue() ) {
            self.completionHandler? (data,error)
        }
    }
}




