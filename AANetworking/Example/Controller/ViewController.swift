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
        
        let movieResource = WebRequestResources.movieResource()
        WebServiceOperation.instantiate().loadJSON(movieResource) { (data, error) in
            guard let movie = (data as? [Movie]) else {
                // Display Some Error
                return }
            print(movie)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



typealias JSONDictionary = [String : AnyObject]

class WebRequestResources {
    

    class func movieResource () -> Resource<[Movie]> {
        let type : OperationType = .topRated
        let resource = Resource<[Movie]>   (urlString: type.url ,operationType : type, parse: { dictionaries in
            guard let results : [AnyObject] = dictionaries["results"] as? [AnyObject] else { return nil }
            return results;
        })
        return resource
    }
    
}

class Spinner : UIView {
    
    let activityIndicater  = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    internal static let sharedInstance = Spinner ()
    
    func showSpinner(inView sourceView:UIView) {
        activityIndicater.hidesWhenStopped = true
        sourceView.addSubview(activityIndicater)
        var center = sourceView.center
        center.x = sourceView.center.x - sourceView.frame.origin.x;
        center.y = sourceView.center.y - sourceView.frame.origin.y;
        activityIndicater.center = center
        activityIndicater.startAnimating()
    }
    
    func hideSpinner(inView sourceView:UIView) {
        activityIndicater.removeFromSuperview()
        activityIndicater.stopAnimating()
    }
}


