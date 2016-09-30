//
//  WebRequest.swift
//  AANetworking
//
//  Created by Ankit Angra on 26/09/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

class WebRequest : NSObject {
    
    fileprivate var errorLogString = NSMutableString ()
    fileprivate var multipartBoundary : String!
    fileprivate var request : NSMutableURLRequest!
    fileprivate var requestURL : URL!
    fileprivate var startDate : Date!
    fileprivate var completionHandler : WebRequestorCompletionHandler?
    fileprivate var retryCount = 0
   
    fileprivate var maximunNumberOfRetry : Int {
        get {
            return 3
        }
    }
    
    fileprivate var timeOut : Double {
        get {
            return 60.0 * Double(retryCount + 1)
        }
    }
    
    /// This method hits the server with the request constructed by the caller
    func sendRequest () {
        startDate = Date()
    
        URLSession.shared.dataTask(with: self.request as URLRequest, completionHandler: { (data, response, error) in
            let timeSpent = Date().timeIntervalSince(self.startDate)
            self.errorLogString.append ("Time Spent for the Request \(String(describing: self.requestURL!)) is \(timeSpent) \n")
            self.errorLogString.append ("*******************\n")
            let result = self.validateYourself(data, error: error as NSError?)
            let validator = self.handleInvalidResponseFromServer(result.data!)
            print(self.errorLogString)

            if result.error != nil || validator.error != nil {
                
                if (result.shouldRetry == true || validator.shouldRetry == true) &&
                    self.responds(to: #selector(self.handleRetry))  &&
                    (self.retryCount) < ((self.maximunNumberOfRetry) - 1)
                {
                    self.retryCount = self.retryCount + 1
                    self.handleRetry()
                }
                else {
                    self.informCompletion(withData: result.data, error: result.error)
                }
            }
            else {
                self.informCompletion(withData: result.data, error: validator.error)
            }
        }) .resume()
    }
    
    
    /// This method has to be handled by the base class to support any kind of retry
    func handleRetry () {
        
    }
    
    /// This method has to be implemented by the base class to handle any kind of Invalid Response.
    ///
    /// - parameter response: Any Valid JSON From Server
    ///
    /// - returns: Custom Error due to response
    func handleInvalidResponseFromServer (_ response : JSONDictionary) -> (error : NSError?,shouldRetry : Bool) {
        // Competion Handler
        return (nil,false)
    }
    
    
    /// This method validated the response from the Server
    ///
    /// - parameter data:  This is the raw date we receive from the Server
    /// - parameter error: This parameter is any error which might have happened while getting data from the Server
    ///
    /// - returns: If the validation was successful data parameter will have the JSON. If there was error while validating them, respected error will go in error parameter. shouldRetry will denote if we have to send a retry request or not.
    func validateYourself (_ data : Data?, error : NSError?) -> (data : JSONDictionary?,error : NSError?,shouldRetry : Bool)  {
        func validateJSON (withData data : Data) throws -> AnyObject {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json! as AnyObject
        }
        
        if error != nil {
            self.errorLogString.append ("*******************\n")
            self.errorLogString.append("Connection failed for request = \(String(describing: self.requestURL))\n")
            self.errorLogString.append("Connection failed for Error = \(error?.localizedDescription)\n")
            self.errorLogString.append ("*******************\n")
            return (nil,error,true)
        }
        
        if data == nil {
            self.errorLogString.append ("Response is Nil\n")
            self.errorLogString.append ("*******************\n")
            self.errorLogString.append ("Response for URL \(String(describing: self.requestURL)) is NULL \n")
            let dataError =  NSError (domain: "NoDataAvailable",code: -99,userInfo: [NSLocalizedDescriptionKey: "No data available"])
            return (nil,dataError,true)
        }
        
        let response : AnyObject
        
        do {
            let json = try validateJSON (withData: data!)
            response = json
            self.errorLogString.append ("Response for URL \(String(describing: self.requestURL)) is \(json) \n")
        }
        catch let error as NSError {
            response = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
            self.errorLogString.append("\n\n ######************JSON Parser error in the response - *******#######\n\n\(String(describing: response)) \n\n")
            return (nil,error,false)
        }
        
        guard let dictionaries = response as? JSONDictionary else {
            let dataError =  NSError (domain: "JSONError",code: -98,userInfo: [NSLocalizedDescriptionKey: "Invalid JSON Received"])
            return (nil,dataError,false)
        }
        
        return (dictionaries,nil,false)
    }
    
    
    /// This method creates a POST Request
    ///
    /// - parameter data:        Data which has to be sent to the server
    /// - parameter url:         The URL to which the request has to be send
    /// - parameter contentType: Content Type of the request
    /// - parameter completion:  This completion handler is called after we receive the data or error back from server
    func postRequest (withData data: Data, url : URL, contentType :RequestContentType, completion:@escaping WebRequestorCompletionHandler) {
        let sessionID : String = "Your Cookie"
        let privateKey : String = "Your Private Key"
        
        var pHash : String! = nil
        var postData : Data
        let timeStamp = Date().timeIntervalSince1970
        requestURL = url
        
        completionHandler = completion
        request =  NSMutableURLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
        request.httpMethod = "POST"
        request.setValue(String(data.count), forHTTPHeaderField: "Content-Length")
        var headerContentType : String
        switch  contentType {
        case .urlEncoded :
            headerContentType = "application/x-www-form-urlencoded"
        case .json :
            headerContentType = "application/json"
        case .multipart:
             headerContentType = "multipart/form-data; boundary=" + multipartBoundary
        default:
            headerContentType = "application/x-www-form-urlencoded"
        }
        request.setValue(headerContentType, forHTTPHeaderField: "Content-Type")
        
        if sessionID != nil
        {
            request.setValue(sessionID, forHTTPHeaderField: "Cookie")
        }
        
        if privateKey != nil {
            let timeInterval = String (timeStamp)
            pHash = generateHMAC(key:privateKey , data: timeInterval)
            request.setValue(pHash, forHTTPHeaderField: "pHash")
        }
        
        if contentType == .urlEncoded {
             var datastring = String(data: data, encoding: String.Encoding.utf8)
            datastring =  "dtm=\(timeStamp)" + datastring!
            postData = (datastring?.data(using: String.Encoding.utf8))!
        }
        else {
            postData = data
        }
        
        request.httpBody = postData
        
        errorLogString.append ("*******************\n")
        errorLogString.append("Request Type: POST \n")
        errorLogString.append("Url: \(String(describing: url))\n")
        errorLogString.append("Cookie: \(String(sessionID)) \n")
        errorLogString.append("pHash: \(pHash)")
        errorLogString.append("Body: \(String(data: postData, encoding: String.Encoding.utf8))")
        errorLogString.append ("*******************\n")
        self.sendRequest()
    }
    
    
    /// This methos creats a GET Request
    ///
    /// - parameter url:        The URL to which the request has to be send
    /// - parameter completion: This completion handler is called after we receive the data or error back from server
    func getRequest (_ url : URL, completion: @escaping WebRequestorCompletionHandler) {
        
        let sessionID : String = "Your Cookie"
        let privateKey : String = "Your Private Key"
        var pHash : String! = nil
        let timeStamp = Date().timeIntervalSince1970
        
        completionHandler = completion
        request =  NSMutableURLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
        request.httpMethod = "GET"
        let headerContentType = "application/x-www-form-urlencoded"
        request.setValue(headerContentType, forHTTPHeaderField: "Content-Type")
        request.setValue(sessionID, forHTTPHeaderField: "Cookie")
        requestURL = url
        
        if privateKey != nil {
            let timeInterval = String (timeStamp)
            pHash = generateHMAC(key:privateKey , data: timeInterval)
            request.setValue(pHash, forHTTPHeaderField: "pHash")
        }
        
        errorLogString.append ("*******************\n")
        errorLogString.append("Request Type: GET \n")
        errorLogString.append("Url: \(String(describing: url))\n")
        errorLogString.append("Cookie: \(String(sessionID)) \n")
        errorLogString.append("pHash: \(pHash)")
        errorLogString.append ("*******************\n")
        self.sendRequest()
    }
}

extension WebRequest {
    /// This is the method which will call the completion Handler
    ///
    /// - parameter data:        data which has to send back
    /// - parameter error:       error which has to send back
    /// - parameter shouldRetry: shouldRetry the request
    func informCompletion(withData data: JSONDictionary?, error: NSError?) {
            self.completionHandler? (data,error)
    }
}

extension WebRequest {
    
    
    /// This method genrates the pHash sent to the server
    ///
    /// - parameter key:  dtm to genrate pHash
    /// - parameter data: private key to genrate pHash
    func generateHMAC(key: String, data: String) -> String {
        
        var result: [CUnsignedChar]
        if let cKey = key.cString(using: String.Encoding.utf8),
            let cData = data.cString(using: String.Encoding.utf8)
        {
            let algo  = CCHmacAlgorithm(kCCHmacAlgSHA512)
            result = Array(repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
            
            CCHmac(algo, cKey, cKey.count-1, cData, cData.count-1, &result)
        }
        else {
            // as @MartinR points out, this is in theory impossible
            // but personally, I prefer doing this to using `!`
            fatalError("Nil returned when processing input strings as UTF8")
        }
        
        let outputData = NSData(bytes: result as [UInt8], length: result.count * MemoryLayout<CUnsignedChar>.size )
        
        let encodedData = outputData.base64EncodedData(options: [.endLineWithLineFeed])
        return String(data: encodedData, encoding: String.Encoding.utf8)!
    }
}


