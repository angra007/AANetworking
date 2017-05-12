//
//  WebRequest.swift
//  https://github.com/angra007/AANetworking
//  Copyright (c) 2013-16 Ankit Angra.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

class WebRequest : NSObject {
    
    fileprivate var errorLogString = NSMutableString ()
    fileprivate var multipartBoundary : String!
    fileprivate var request : NSMutableURLRequest!
    fileprivate var requestURL : URL!
    fileprivate var startDate : Date!
    fileprivate var completionHandler : WebRequestorCompletionHandler?
    fileprivate var retryCount = 0
    fileprivate var currentTask : URLSessionDataTask!
    
    
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
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    /// This method hits the server with the request constructed by the caller
    func sendRequest () {
        startDate = Date()

        currentTask = downloadsSession.dataTask(with: self.request as URLRequest, completionHandler: { (data, response, error) in
            let timeSpent = Date().timeIntervalSince(self.startDate)
            self.errorLogString.append ("Time Spent for the Request \(String(describing: self.requestURL!)) is \(timeSpent) \n")
            self.errorLogString.append ("*******************\n")
            let result = self.validateYourself(data, error: error as NSError?)
            
            var validator : (error : NSError?,shouldRetry : Bool) = (nil,false)
            if let data = result.data {
                validator = self.handleInvalidResponseFromServer(data)
            }
            
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
        })
        WebServiceManager.sharedManager.addTask(currentTask)
        currentTask.resume()
    }
    
    /// This method has to be handled by the base class to support savind of the logs
    func saveLog () {
        
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
        
        func dataWithEscapingTabSpaces(withData data : Data) -> Data {
            let string = String.init(data: data, encoding: String.Encoding.utf8)
            let nospacestring : String! = string?.replacingOccurrences(of: "\\t", with: "    ", options:  .regularExpression, range: (string?.startIndex)!..<(string?.endIndex)!)
            return nospacestring.data(using: String.Encoding.utf8)!
        }
        
        func validateJSON (withData data : Data) throws -> AnyObject? {
            let escapedData = dataWithEscapingTabSpaces(withData: data)
            let json = try? JSONSerialization.jsonObject(with: escapedData, options: [])
            return json as? AnyObject
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
            let url = String(describing: self.requestURL)
            self.errorLogString.append ("Response for URL \(url) is NULL \n")
            let dataError =  NSError (domain: "NoDataAvailable",code: -99,userInfo: [NSLocalizedDescriptionKey: "No data available"])
            return (nil,dataError,true)
        }
        
        let response : AnyObject?
        
        do {
            let json = try validateJSON (withData: data!)
            
            if let validJSON = json {
                response = validJSON
            }
            else {
                response = nil
            }
            
            self.errorLogString.append ("Response for URL \(self.requestURL.absoluteString) is \(json!) \n")
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
        var sessionID : String? = nil

        let sessionIDs = HTTPCookieStorage.shared.cookies(for: url)
        if let cookie = sessionIDs?.last {
            sessionID =  "JSESSIONID=\(cookie.value) Path=\(cookie.path) Secure"
        }

        var privateKey : String! = nil
        if WebServiceManager.sharedManager.pKey != nil {
             privateKey  =  WebServiceManager.sharedManager.pKey
        }
        
        var pHash : String! = nil
        var postData : Data
        let timeStamp = Int (Date().timeIntervalSince1970)
        requestURL = url
        
        completionHandler = completion
        request =  NSMutableURLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
        request.httpMethod = "POST"
        
        if contentType == .urlEncoded {
            var datastring = String(data: data, encoding: String.Encoding.utf8)
            
            if privateKey != nil {
               datastring = "dtm=\(timeStamp)" + datastring!
            }
            else {
                datastring = datastring!
            }
            postData = (datastring?.data(using: String.Encoding.utf8))!
        }
        else {
            postData = data
        }
        
        request.setValue(String(postData.count), forHTTPHeaderField: "Content-Length")
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
        
        if let key = privateKey {
            let timeInterval = String (timeStamp)
            pHash =  NetworkUtility.hashedBase64Value(ofData: timeInterval, withKey: key)
            request.setValue(pHash!, forHTTPHeaderField: "pHash")
        }
        
        request.httpBody = postData
        
        errorLogString.append ("*******************\n")
        errorLogString.append("Request Type: POST \n")
        errorLogString.append("Url: \(String(describing: url))\n")
        if let id = sessionID {
            errorLogString.append("Cookie: \(id) \n")
        }
        
        if  privateKey != nil {
            errorLogString.append("pHash: \(pHash!) \n")

        }
        errorLogString.append("HeaderContentType: \(headerContentType) \n")
        errorLogString.append("Body: \(String(data: postData, encoding: String.Encoding.utf8)!) \n")
        errorLogString.append ("*******************\n")
        self.sendRequest()
    }
    
    
    /// This methos creats a GET Request
    ///
    /// - parameter url:        The URL to which the request has to be send
    /// - parameter completion: This completion handler is called after we receive the data or error back from server
    func getRequest (_ url : URL, completion: @escaping WebRequestorCompletionHandler) {
        
        var sessionID : String? = nil
        
        let sessionIDs = HTTPCookieStorage.shared.cookies(for: url)
        if let cookie = sessionIDs?.last {
            sessionID =  "JSESSIONID=\(cookie.value) Path=\(cookie.path) Secure"
        }
        
        var privateKey : String! = nil
        if WebServiceManager.sharedManager.pKey != nil {
            privateKey  = WebServiceManager.sharedManager.pKey
        }
        var pHash : String! = nil
        let timeStamp = Int (Date().timeIntervalSince1970 )
        
        let getURL = URL.init(string: url.absoluteString + "dtm=\(timeStamp)")!
        
        
        completionHandler = completion
        request =  NSMutableURLRequest.init(url: getURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
        request.httpMethod = "GET"
        let headerContentType = "application/x-www-form-urlencoded"
        request.setValue(headerContentType, forHTTPHeaderField: "Content-Type")
        requestURL = getURL

        if let key = privateKey {
            let timeInterval = String (timeStamp)
            pHash =  NetworkUtility.hashedBase64Value(ofData: timeInterval, withKey: key)
            request.setValue(pHash!, forHTTPHeaderField: "pHash")
        }
        
        errorLogString.append ("*******************\n")
        errorLogString.append("Request Type: GET \n")
        errorLogString.append("Url: \(String(describing: getURL))\n")
        if let id = sessionID {
            errorLogString.append("Cookie: \(id) \n")
        }
        
        errorLogString.append("pHash: \(pHash!)\n")
        errorLogString.append ("*******************\n")
        self.sendRequest()
    }
}

extension WebRequest : URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let servertrust = challenge.protectionSpace.serverTrust
        
        if let trust = servertrust {
            let trust_credential = URLCredential.init(trust: trust)
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    completionHandler(.useCredential, trust_credential)
            }
            else {
                completionHandler(.performDefaultHandling, trust_credential)
            }
        }
        else {
            challenge.sender?.cancel(challenge)
            completionHandler (.cancelAuthenticationChallenge, nil)
        }
    }
}

extension WebRequest {
    /// This is the method which will call the completion Handler
    ///
    /// - parameter data:        data which has to send back
    /// - parameter error:       error which has to send back
    /// - parameter shouldRetry: shouldRetry the request
    func informCompletion(withData data: JSONDictionary?, error: NSError?) {
        downloadsSession.invalidateAndCancel()
        self.completionHandler? (data,error,errorLogString)
    }
}


