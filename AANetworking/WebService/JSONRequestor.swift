//
//  WANDJSONRequestor.swift
//  AANetworking
//
//  Created by Ankit Angra on 27/09/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

class JSONRequestor : WebRequest {
    
    override func handleInvalidResponseFromServer(response: JSONDictionary) -> (error: NSError?, shouldRetry: Bool) {
        guard let results : [String:AnyObject] = response["data"] as? [String:AnyObject] else { return (nil,false) }
        guard let status : String = results["status"] as? String else {return (nil,false)}
        
        if status == "500" || status == "501" || status == "1000" {
            let invalidRequestError =  NSError (domain: "JSONError",code: -97,userInfo: [NSLocalizedDescriptionKey: "Request is Invalid"])
            return (invalidRequestError,false)
        }
        else {
            return (nil,false)
        }
    }
}

