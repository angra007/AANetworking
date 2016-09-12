//
//  Cache.swift
//  AANetworking
//
//  Created by Ankit Angra on 29/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation

class Cache : NSObject {
    
    static let sharedCache = Cache ()
    var catchNameDictionary = [String:AnyObject]()
    var path : NSURL!
 
    convenience  init(type : CacheType) {
        self.init()
        path = self.cachePath (withName : type.rawValue)
    }
    
    internal func data (forURL url:String, timestamp : NSDate) -> NSData? {
        return data(forKey:  key(forURL: url), timestamp: timestamp)
    }
    
    internal func data (forKey key: String, timestamp : NSDate) -> NSData? {
       let filePath = path.URLByAppendingPathComponent(key).path!
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath) {
            do {
                let fileAttributes = try fileManager.attributesOfItemAtPath(filePath)
                let modified = fileAttributes[NSFileModificationDate]

                let dateComparisionResult:NSComparisonResult = (modified?.compare(timestamp))!
                
                if dateComparisionResult == NSComparisonResult.OrderedSame ||  dateComparisionResult == NSComparisonResult.OrderedAscending {
                    do {
                        return try NSData(contentsOfFile: filePath, options: NSDataReadingOptions.DataReadingMappedAlways)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        return nil
                    }
                    catch {
                        print("Some Error")
                        return nil
                    }
                }
                else {
                     do {
                        try  fileManager.removeItemAtURL( NSURL (string:filePath)!)
                        return nil
                     }
                     catch let error as NSError {
                        print(error.localizedDescription)
                        return nil
                     }
                     catch {
                         print("Some Error")
                         return nil
                    }
                 }
            } catch let error as NSError{
                print(error.localizedDescription)
                return nil
            }
            catch {
                 print("Some Error")
                return nil
               
            }
        }
        else {
            return nil
        }
    }
    
    internal func store (data:NSData?,forURL url:String, timestamp : NSDate) {
        
        var pHash = key(forURL: url)
        pHash = pHash.stringByReplacingOccurrencesOfString("/", withString: "")
        
        store(data, forKey: pHash, timestamp: timestamp)
    }
    
    internal func store (data:NSData?,forKey key:String, timestamp : NSDate) {
        let filePath =  path.URLByAppendingPathComponent(key).path!
        if let data = data {
            print(data.length)
            do {
                    try data.writeToFile(filePath, options: .AtomicWrite)
            } catch let error as NSError{
                print(error.localizedDescription)
            }
         }
    }
    
    internal func removeDownloadedAssets(forURL url:String) {
        let filePath = path.URLByAppendingPathComponent(key(forURL: url)).path!
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath) {
           do {
                try fileManager.removeItemAtPath(filePath)
            }
           catch let error as NSError {
                print(error.localizedDescription)
            }
           catch {
                print("Some Error")
            }
        }
    }
    
    private func key (forURL url:String) -> String {
        return SHA2(url)!
    }
    
    private func SHA2 (url:String) -> String? {
        guard
            let data = url.dataUsingEncoding(NSUTF8StringEncoding),
            let shaData = sha256(data)
            else { return nil }
        let output = shaData.base64EncodedStringWithOptions([])
        return output
    }
    
    private func sha256(data: NSData) -> NSData? {
        guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
        CC_SHA256(data.bytes, CC_LONG(data.length), UnsafeMutablePointer(res.mutableBytes))
        return res
    }
    
    private func cachePath (withName name: String) -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let cachePath = documentsURL.URLByAppendingPathComponent(name)
        createPathIfNecessary(cachePath.path!)
        return cachePath
    }
    
    private func createPathIfNecessary (filePath:String) {
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(filePath) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(filePath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            catch {
                print("Some Error")
            }
        }
    }
}