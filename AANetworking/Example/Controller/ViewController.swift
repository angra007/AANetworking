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

        NetworkHelper.load(url: "url", parse: { (dict) -> AnyObject? in
            // This is your parser. Return modeled data from here
            
            return dict as? AnyObject
        }) { (data, error, status) in
            
            // This is your completion handler
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}






