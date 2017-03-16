//
// Constants.swift
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

let key : String = "4c989ba3813652e9f29d4dfd44bd34ad"

import Foundation

public typealias JSONDictionary = [String : AnyObject]
public typealias WebServiceCompletionHandler = ((AnyObject?, NSError?,NSString,String?) -> Void)
public typealias ProcessDownloadCompletionHandler = ((JSONDictionary) -> AnyObject?)
public typealias WebRequestorCompletionHandler = (([String:AnyObject]?, NSError?,NSString) -> Void)

public enum RequestContentType  : Int {
    case none = 0
    case urlEncoded = 1
    case json = 2
    case multipart = 3
}

public enum RequestMethodType {
    case get
    case post
}
