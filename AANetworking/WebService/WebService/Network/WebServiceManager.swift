//
// WebServiceManager.swift
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
