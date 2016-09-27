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
            self.errorLogString.appendString("Time spent in request \(String(self.requestURL)) is \(String(timeSpent))\n")
            self.validateYourself(data, error: error)
            print (self.errorLogString)
            }.resume()
    }
    
    func validateYourself (data : NSData?, error : NSError?) {
        
        func validateJSON (withData data : NSData) throws -> AnyObject {
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            return json!
        }
        
        if error != nil {
            self.errorLogString.appendString ("*******************\n")
            self.errorLogString.appendString("Connection failed for request = \(String(self.requestURL))\n")
            self.errorLogString.appendString("Connection failed for Error = \(error?.localizedDescription)\n")
            self.errorLogString.appendString ("*******************\n")
            self.informCompletion(withData: nil, error: error, shouldRetry: true)
            return
        }
        
        if data == nil {
            self.errorLogString.appendString ("Response is Nil\n")
            self.errorLogString.appendString ("*******************\n")
            self.errorLogString.appendString ("Response for URL \(String(self.requestURL)) is NULL \n")
            let dataError =  NSError (domain: "NoDataAvailable",code: -99,userInfo: [NSLocalizedDescriptionKey: "No data available"])
            self.informCompletion(withData: nil, error: dataError , shouldRetry: true)
            return
        }
        
        let json : AnyObject
        
        do {
            json = try validateJSON (withData: data!)
            self.errorLogString.appendString ("Response for URL \(String(self.requestURL)) is \(json) \n")
        }
        catch let error as NSError{
            let response = NSString(data: data!, encoding: NSUTF8StringEncoding)
            self.errorLogString.appendString("\n\n ######************JSON Parser error in the response - *******#######\n\n\(String(response)) \n\n")
            self.informCompletion(withData: nil, error: error , shouldRetry: false)
        }
    }
}