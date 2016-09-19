//
//  File.swift
//  WebService
//
//  Created by Ankit Angra on 22/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

final class WebServiceManager : NSObject {
    
    private let requestQueue = NSOperationQueue()
    
    deinit {
        cancelAllrequests()
    }
}

extension WebServiceManager {
    func cancelAllrequests() {
        requestQueue.cancelAllOperations()
    }
    
    func cancelOperationWithOperationType (type : OperationType) {
        let operations = requestQueue.operations
        for operation in operations where (operation as? WebServiceOperation)?.operationType == type {
            operation.cancel()
        }
    }
    
}

extension WebServiceManager {
    func addRequest (request : WebServiceOperation) {
        requestQueue.addOperation(request)
    }
}






