//
//  File.swift
//  WebService
//
//  Created by Ankit Angra on 22/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

/**
    This is a Singleton class which act as a Manager for all the type of requests. The job of this class is to add a operation in
    the operation queue and to remove the operation from the queue as and when required.
 */
final class WebServiceManager : NSObject {
    
    private let requestQueue = NSOperationQueue()
    
    static let sharedManager = WebServiceManager()
    
    deinit {
        cancelAllrequests()
    }
}

extension WebServiceManager {
    /**
        Method to Cancel all the request in the Queue
     */
    func cancelAllrequests() {
        requestQueue.cancelAllOperations()
    }
    
    /**
        Method to cancel a specific operation
     */
    func cancelOperationWithOperationType (type : OperationType) {
        let operations = requestQueue.operations
        for operation in operations where (operation as? WebServiceOperation)?.operationType == type {
            operation.cancel()
        }
    }
    
    /**
        Method to add a operation in the Queue
    */
    func addRequest (request : WebServiceOperation) {
        requestQueue.addOperation(request)
    }
    
}







