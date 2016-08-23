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

        
        WebServiceOperation.sharedWebService.load(WebRequestResources.sharedRequestResource.movieResource()) { (data, error) in
            guard let movie = (data as? [Movie]) else {
                // Display Some Error
                return }
            let firstMovie : Movie = movie[0]
            print(firstMovie.originalLanguage)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

