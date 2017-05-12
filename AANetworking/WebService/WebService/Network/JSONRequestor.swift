//
// JSONRequestor.swift
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
