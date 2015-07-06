//
//  AlertController.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/21/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class ErrorAlert {
    
    static func create(errorTitle: String, errorMessage: String, viewController: UIViewController) {
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let image = UIImage(named: "error")
        let imageView = UIImageView(image: image)
        imageView.frame.origin.x += 11
        imageView.frame.origin.y += 11
        imageView.frame.size.width -= 7
        imageView.frame.size.height -= 7
        alert.view.addSubview(imageView)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        
        if viewController.presentedViewController == nil {
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
        
    }

}
