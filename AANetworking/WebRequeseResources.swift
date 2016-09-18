//
//  WebRequeseResources.swift
//  AANetworking
//
//  Created by Ankit Angra on 23/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation
import UIKit

struct Resource <A> {
    let urlString : String
    let operationType : OperationType
    let parse : ( (NSData) throws -> Any?)
}

struct MediaResource <A> {
    let urlString : String
    let modificationDate : NSDate
    let saveInCache : ( (NSData) throws -> Any?)
}




