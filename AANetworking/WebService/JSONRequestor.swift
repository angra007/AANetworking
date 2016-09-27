//
//  WANDJSONRequestor.swift
//  AANetworking
//
//  Created by Ankit Angra on 27/09/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

class JSONRequestor : WebRequest {
    
    override func sendRequest() {
        startDate = NSDate()
        NSURLSession.sharedSession().dataTaskWithRequest(self.request!) { (data, response, error) in
            let timeSpent = NSDate.timeIntervalSinceDate(self.startDate)
            self.errorLogString.appendString("Time spent in request \(String(self.requestURL!)) is \(timeSpent)\n")
            let result = self.validateYourself(data, error: error)
            print (self.errorLogString)
            self.informCompletion(withData: result.data, error: result.error , shouldRetry: result.shouldRetry)
        }.resume()
    }
    
    func validateYourself (data : NSData?, error : NSError?) -> (data : AnyObject?,error : NSError?,shouldRetry : Bool)  {
        
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
        
        guard let dictionaries = response as? [String:AnyObject] else {
            let dataError =  NSError (domain: "JSONError",code: -98,userInfo: [NSLocalizedDescriptionKey: "Invalid JSON Received"])
            return (nil,dataError,false)
        }
        
        return (dictionaries,nil,false)
    }
}

extension JSONRequestor {
    func informCompletion(withData data: AnyObject?, error: NSError?,shouldRetry : Bool) {
        dispatch_async(dispatch_get_main_queue() ) {
            self.completionHandler? (data,error,shouldRetry)
        }
    }
}