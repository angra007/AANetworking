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
    var completionHandler : WebRequestorCompletionHandler?
    
    func sendRequest () {
        startDate = NSDate()
        NSURLSession.sharedSession().dataTaskWithRequest(self.request!) { (data, response, error) in
            let timeSpent = NSDate.timeIntervalSinceDate(self.startDate)
            print(timeSpent)
            
            let result = self.validateYourself(data, error: error)
            if result.error != nil {
                self.informCompletion(withData: result.data, error: result.error, shouldRetry: result.shouldRetry)
            }
            else {
                let validator = self.handleInvalidResponseFromServer(result.data!)
                print(self.errorLogString)
                self.informCompletion(withData: result.data, error: validator.error, shouldRetry: validator.shouldRetry)
            }
        }.resume()
    }
    
    /**
        This method has to be implemented by the base class to handle any kind of Invalid Response. 
        @param response : Any Valid JSON From Server
        
        @return
        error : Custom Error due to response
        shouldRetry : Whether the request should go again
    */
    func handleInvalidResponseFromServer (response : JSONDictionary) -> (error : NSError?,shouldRetry : Bool) {
        // Competion Handler
        return (nil,false)
    }
    
    
    func validateYourself (data : NSData?, error : NSError?) -> (data : JSONDictionary?,error : NSError?,shouldRetry : Bool)  {
        func validateJSON (withData data : NSData) throws -> AnyObject {
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            return json!
        }
        
        if error != nil {
            self.errorLogString.appendString ("*******************\n")
            self.errorLogString.appendString("Connection failed for request = \(String(self.requestURL!))\n")
            self.errorLogString.appendString("Connection failed for Error = \(error?.localizedDescription)\n")
            self.errorLogString.appendString ("*******************\n")
            return (nil,error,true)
        }
        
        if data == nil {
            self.errorLogString.appendString ("Response is Nil\n")
            self.errorLogString.appendString ("*******************\n")
            self.errorLogString.appendString ("Response for URL \(String(self.requestURL!)) is NULL \n")
            let dataError =  NSError (domain: "NoDataAvailable",code: -99,userInfo: [NSLocalizedDescriptionKey: "No data available"])
            return (nil,dataError,true)
        }
        
        let response : AnyObject
        
        do {
            let json = try validateJSON (withData: data!)
            response = json
            self.errorLogString.appendString ("Response for URL \(String(self.requestURL!)) is \(json) \n")
        }
        catch let error as NSError {
            response = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            self.errorLogString.appendString("\n\n ######************JSON Parser error in the response - *******#######\n\n\(String(response)) \n\n")
            return (nil,error,false)
        }
        
        guard let dictionaries = response as? JSONDictionary else {
            let dataError =  NSError (domain: "JSONError",code: -98,userInfo: [NSLocalizedDescriptionKey: "Invalid JSON Received"])
            return (nil,dataError,false)
        }
        
        return (dictionaries,nil,false)
    }
    
    func postRequest (withData data: NSData, url : NSURL, contentType :RequestContentType, completion:WebRequestorCompletionHandler) {
        let sessionID = ""
        //let privateKey = "lmnop"
        completionHandler = completion
        request =  NSMutableURLRequest.init(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
        request?.HTTPMethod = "POST"
        request?.setValue(String(data.length), forHTTPHeaderField: "Content-Length")
        var headerContentType : String
        switch  contentType {
        case .URLEncoded :
            headerContentType = "application/x-www-form-urlencoded"
        case .JSON :
            headerContentType = "application/json"
        case .Multipart:
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
        self.sendRequest()
    }
    
    func getRequest (url : NSURL, completion: WebRequestorCompletionHandler) {
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
        self.sendRequest()
    }
}

extension WebRequest {
    func informCompletion(withData data: JSONDictionary?, error: NSError?,shouldRetry : Bool) {
        dispatch_async(dispatch_get_main_queue() ) {
            self.completionHandler? (data,error,shouldRetry)
        }
    }
}




