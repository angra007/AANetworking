//
//  NetworkHelper.swift
//  Wand
//
//  Created by Ankit on 03/02/17.
//  Copyright © 2017 Pro Unlimited Inc. All rights reserved.
//

import Foundation
import WandCore

class NetworkHelper {
    
    
    class func load (url : String, parse : @escaping ProcessDownloadCompletionHandler, completion : @escaping ((AnyObject?, NSError?,String?) -> Void) ) {
        let resource = Resource<Any> (url : url, parse: parse)
        NetworkHelper.sendRequest(resource,completion: completion)
    }
    
    class func load(url : String, contentType : RequestContentType,data : Data, parse : @escaping ProcessDownloadCompletionHandler, completion : @escaping ((AnyObject?, NSError?,String?) -> Void) ) {
        let resource = Resource<Any> (url : url, contentType: contentType, postData: data, parse: parse)
        NetworkHelper.sendRequest(resource,completion: completion)
    }
    
    class func load (url : String, data : Data,multipartBoundry : String, parse : @escaping ProcessDownloadCompletionHandler, completion : @escaping ((AnyObject?, NSError?,String?) -> Void) ) {
        let resource = Resource<Any> (url : url, postData: data, multipartBoundry: multipartBoundry, parse: parse)
        NetworkHelper.sendRequest(resource,completion: completion)
    }
    
    class func sendRequest <A>(_ resource: Resource<A>, completion:@escaping ((AnyObject?, NSError?,String?) -> Void)) {
       
        if isInternetActive() == true {
            let webServce : WebServiceOperation! = WebServiceOperation ()
            webServce.loadJSON(resource) { (data, error, log,currentStatus) in
                
                if let status = currentStatus {//WAMO-7994
                    if status == "502" {
                        if WANDLoginManager.shared().isLoggedIn == true {
                            let title = WANDErrorDescriptionManager.shared().errorTitle(forErrorCode: Int(status)! )
                            
                            WANDAlertView.alert(withTitle: title!, message: nil, completion: { (buttonIndex) in
                                WANDWorkerUtility.cleanup()
                                WANDLoginManager.shared().logout()
                                WANDWorkerDataSource.shared().clearDatasource()
                                APP_DELEGATE?.viewController.presentedViewController?.dismiss(animated: true, completion: {
                                    APP_DELEGATE?.viewController.displayAppropriateController()
                                })
                                
                            }, cancelButtonTitle: "Ok", otherButtonTitles: nil)
                        }
                    }
                    else if status == "500" || status == "501" || status == "1000" {
                        WandErrorHandlerUtility.sharedRequestWebServiceErrorHandlerUtilities().sendLog()
                        completion (data, error,currentStatus)
                        //webServce = nil
                    }
                    else {
                        completion (data, error,currentStatus)
                        //webServce = nil
                    }
                }
                else {
                    
                    if isInternetActive() == true {
                        let title = WANDErrorDescriptionManager.shared().errorTitle(forErrorCode: Int(eGeneralError.rawValue) )
                        WANDActionItemsModelObject.shared().requestApprovalStatus = eFailed
                        WANDAlertView.alert(withTitle: title!, message: nil, completion: { (buttonIndex) in
                            WandErrorHandlerUtility.sharedRequestWebServiceErrorHandlerUtilities().sendLog()
                        }, cancelButtonTitle: "Ok", otherButtonTitles: nil)
                        completion (data, error,currentStatus)
                    }
                    else {
                        completion (nil, error,nil)
                    }
                    //webServce = nil
                }
            }
        }
        else {
            WebServiceManager.sharedManager.cancelAllRequests()
            let noInternetError =  NSError (domain: "JSONError",code: -1000,userInfo: [NSLocalizedDescriptionKey: "Internet connection not available"])
            completion (nil, noInternetError,nil)
        }
    }
    
    class func isInternetActive () -> Bool {
        
        var reachable = true
        
        let internetStatus = Reachability.forInternetConnection().currentReachabilityStatus ()
        
        if internetStatus == NotReachable {
            reachable = false
        }
        return reachable
    }
    
    class func cancelRequest (forUrl url: String) {
    
        WebServiceManager.sharedManager.removeTaskFromQueue(withUrl: url)
    
    }

    class func cancelAllRequest () {
        WebServiceManager.sharedManager.cancelAllRequests()
    }
    
}
