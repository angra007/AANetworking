//
//  ActivityIndicator.swift
//  AANetworking
//
//  Created by Ankit Angra on 29/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import UIKit

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
