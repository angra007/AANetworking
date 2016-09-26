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
//        WebServiceOperation.instantiate().load(movieResource) { (data, error) in
//            guard let movie = (data as? [Movie]) else {
//                // Display Some Error
//                return }
//            print(movie)
//        }
//        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIImageView {
    
    internal func setImage (withURL url :String,fromDisk:Bool,modificationDate:NSDate,placeHolderImage : UIImage?,shouldShowActivityIndicator:Bool) {
        self.image = placeHolderImage
        
        if shouldShowActivityIndicator {
            Spinner.sharedInstance.showSpinner(inView : self)
        }
        
        //let resource = WebRequestResources.imageResource(urlString : url,modificationDate: modificationDate)
        
        
//        WebServiceOperation.instantiate().loadMedia(resource) { (data, error) in
//            
//            guard let image = (data as? UIImage) else {
//                // Display Some Error
//                return }
//            Spinner.sharedInstance.hideSpinner(inView : self)
//            self.image = image
//        }
    }
}

typealias JSONDictionary = [String : AnyObject]

class WebRequestResources {
    
    // Sample Resource
//    class func movieResource () -> Resource<[Movie]> {
//        let type : OperationType = .topRated
//        let resource = Resource<[Movie]>(urlString: type.url ,operationType : type, parse: { data in
//            // Parse your model object here and return parsed object
//            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
//            guard let dictionaries = json as? [String:AnyObject] else { return nil }
//            guard let results : [AnyObject] = dictionaries["results"] as? [AnyObject] else { return nil }
//            return results.flatMap() {
//                Movie.init(movieDetails: $0 as! JSONDictionary)
//            }
//        })
//        return resource
//    }
    
//    class func imageResource (urlString url:String, modificationDate : NSDate) -> MediaResource<UIImage>  {
//        let resource = MediaResource<UIImage>(urlString: url, modificationDate: modificationDate, saveInCache: { (data) -> Any? in
//            // Save Image in Cache Here
//            let cache = Cache (type :.Asserts)
//            cache.store(data, forURL: url, timestamp: modificationDate)
//            return data
//        })
//        return resource
//    }
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


