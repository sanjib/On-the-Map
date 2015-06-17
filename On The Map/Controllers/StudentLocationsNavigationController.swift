//
//  MapAndTableNavigationController.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/9/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class StudentLocationsNavigationController: UINavigationController {

    var isUserCurrentlyLoggedInToFacebook: Bool {
        get {
            if FBSDKAccessToken.currentAccessToken() != nil {
                return true
            } else {
                return false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadStudentLocations", name: "reloadStudentLocations", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationItem = UINavigationItem(title: "On The Map")
        
        if isUserCurrentlyLoggedInToFacebook {
            let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
            navigationItem.leftBarButtonItem = logoutButton
        } else {
            navigationItem.setHidesBackButton(true, animated: false)
        }
        
        let reloadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadStudentLocations")
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinAnnotation")
        navigationItem.rightBarButtonItems = [reloadButton, pinButton]
        
        self.navigationBar.items.append(navigationItem)
        
    }
    
    func logout() {
        if isUserCurrentlyLoggedInToFacebook {
            FBSDKLoginManager().logOut()
            // reset user / set user to nil
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func pinAnnotation() {
        performSegueWithIdentifier("InformationPostingSegue", sender: self)
    }
    
    func reloadStudentLocations() {
        if self.visibleViewController.restorationIdentifier == "StudentLocationsTable" {
            let vc = self.visibleViewController as! StudentLocationsTableViewController
            vc.reloadStudentLocations()
        } else if self.visibleViewController.restorationIdentifier == "StudentLocationsMap" {
            let vc = self.visibleViewController as! StudentLocationsMapViewController
            vc.reloadStudentLocations()
        } else if self.visibleViewController.restorationIdentifier == "StudentLocationsCollection" {
            let vc = self.visibleViewController as! StudentLocationsCollectionViewController
            vc.reloadStudentLocations()
        }
    }
}
