//
//  JSONRequestor.swift
//  Wand
//
//  Created by Ankit Angra on 03/10/16.
//  Copyright © 2016 Pro Unlimited Inc. All rights reserved.
//

import Foundation

class JSONRequestor : WebRequest {
    
    
    override init() {
        super.init()
    }
    
    deinit {
        print ("JSONRequestor dealloc called")
    }
    
    override func handleInvalidResponseFromServer(_ response: JSONDictionary) -> (error: NSError?, shouldRetry: Bool) {
        
        let invalidRequestError =  NSError (domain: "JSONError",code: -97,userInfo: [NSLocalizedDescriptionKey: "Request is Invalid"])
        
        guard let results : [String:AnyObject] = response["data"] as? [String:AnyObject] else { return (invalidRequestError,true) }
        guard let status : String = results["status"] as? String else {return (nil,false)}
        
        if status == "500" || status == "501" || status == "1000" {
            
            return (invalidRequestError,false)
        }
        else {
            return (nil,false)
        }
    }
    
    override func handleRetry() {
        self.sendRequest()
    }
    
    override func saveLog () {
//        let log = WANDErrorLogModel.init(string: self.errorLogString as String!, shouldBeDeleted: false, shouldSendToServer: false)
//        WandErrorHandlerUtility.sharedRequestWebServiceErrorHandlerUtilities().savelog(log)
    }
}
