//
//  ImageCache.swift
//  AANetworking
//
//  Created by Ankit Angra on 29/08/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import UIKit

extension UIImageView {
    
    internal func setImage (withURL url :String,fromDisk:Bool,modificationDate:NSDate,placeHolderImage : UIImage?,shouldShowActivityIndicator:Bool,trackID : String ) {
        self.image = placeHolderImage
       
        if shouldShowActivityIndicator {
            Spinner.sharedInstance.showSpinner(inView : self)
        }
        
        let resource = WebRequestResources.imageResource(urlString : url,trackingID: trackID,modificationDate: modificationDate)
        
        
        WebServiceOperation.instantiate().loadMedia(resource) { (data, error) in

            guard let image = (data as? UIImage) else {
                // Display Some Error
                return }
            Spinner.sharedInstance.hideSpinner(inView : self)
            self.image = image
        }
    }
}