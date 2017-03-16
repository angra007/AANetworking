//
//  ViewController.swift
//  AANetworking
//
//  Created by Ankit Angra on 23/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let movieResource = WebRequestResources.movieResource()
//        let webservice = WebServiceOperation()
//        webservice.loadJSON(movieResource) { (data, error) in
////            guard let movie = (data as? [Movie]) else {
////                // Display Some Error
////                return }
//            print(data)
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class WebRequestResources {
    
//    class func movieResource () -> Resource<[Movie]> {
//        let resource = Resource<[Movie]>   (operationType : .topRated, parse: { dictionaries in
//            guard let results : [AnyObject] = dictionaries["results"] as? [AnyObject] else { return nil }
//            return results as AnyObject?;
//        })
//        return resource
//    }
    
}




