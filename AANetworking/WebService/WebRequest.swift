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
    var request : NSMutableURLRequest?
    var timeOut = 0.0
    var errorLogString = NSMutableString ()
    var requestURL : NSURL?
    var startDate : NSDate!
    var completionHandler : ((AnyObject?, NSError?,Bool) -> Void)?
    
    func sendRequest () {
        startDate = NSDate()
        NSURLSession.sharedSession().dataTaskWithRequest(self.request!) { (data, response, error) in
            let timeSpent = NSDate.timeIntervalSinceDate(self.startDate)
            print(timeSpent)
            }.resume()
    }
    
    func postRequest (withData data: NSData, url : NSURL, headerType :RequestHeaderFieldType, completion:((AnyObject?, NSError?,Bool) -> Void)) {
        
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
        
        requestURL = url
        errorLogString.appendString ("*******************\n")
        errorLogString.appendString("Request Type: POST \n")
        errorLogString.appendString("Url: \(String(url))\n")
        errorLogString.appendString("Cookie: \(String(sessionID)) \n")
        errorLogString.appendString("Body: \(String(data: data,encoding: NSUTF8StringEncoding))")
        errorLogString.appendString ("*******************\n")
        print(errorLogString)
        
        self.sendRequest()
    }
    
    func getRequest (url : NSURL, completion:((AnyObject?, NSError?,Bool) -> Void)) {
        let sessionID = ""
        completionHandler = completion
        request =  NSMutableURLRequest.init(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
        request?.HTTPMethod = "GET"
        let headerContentType = "application/x-www-form-urlencoded"
        request?.setValue(headerContentType, forHTTPHeaderField: "Content-Type")
        request?.setValue(sessionID, forHTTPHeaderField: "Cookie")
        requestURL = url
        errorLogString.appendString ("*******************\n")
        errorLogString.appendString("Request Type: GET \n")
        errorLogString.appendString("Url: \(String(url))\n")
        errorLogString.appendString("Cookie: \(String(sessionID)) \n")
        errorLogString.appendString ("*******************\n")
        print(errorLogString)
        self.sendRequest()
    }
}

extension WebRequest {
    func informCompletion(withData data: AnyObject?, error: NSError?,shouldRetry : Bool) {
        dispatch_async(dispatch_get_main_queue() ) {
            self.completionHandler? (data,error,shouldRetry)
        }
    }
}




