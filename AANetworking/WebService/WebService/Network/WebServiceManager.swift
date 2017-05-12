//
//  WebServiceManager.swift
//  Wand
//
//  Created by Ankit Angra on 03/10/16.
//  Copyright © 2016 Pro Unlimited Inc. All rights reserved.
//

import Foundation

/// This is a Singleton class which act as a Manager for all the type of requests. The job of this class is to add a operation in the operation queue and to remove the operation from the queue as and when required.
public final class WebServiceManager : NSObject {
    
    public var dataTaskQueue = [URLSessionDataTask]()
    public static let sharedManager = WebServiceManager()
    public var pKey : String! = ""
    
    deinit {
        cancelAllRequests()
    }
}

extension WebServiceManager {
    
    func addTask (_ task:URLSessionDataTask) {
        dataTaskQueue.append(task)
    }
    
    func removeTask (_ task:URLSessionDataTask) {
        dataTaskQueue = dataTaskQueue.filter() {
            if $0.currentRequest?.url?.absoluteString == task.currentRequest?.url?.absoluteString {
                if let index = dataTaskQueue.index(of: task){
                    dataTaskQueue.remove(at: index)
                }
                return true
            }
            return false
        }
    }

    
    public func cancelAllRequests () {
        dataTaskQueue = dataTaskQueue.filter() {
            $0.cancel()
            return true
        }
    }
    
    public func removeTaskFromQueue (withUrl url:String) {
        dataTaskQueue = dataTaskQueue.filter() {
            if $0.currentRequest?.url?.absoluteString == url {
                $0.cancel()
                return true
            }
            return false
        }
    }
}
