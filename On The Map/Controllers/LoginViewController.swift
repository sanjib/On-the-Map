//
//  LoginViewController.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/6/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginFacebookComplete", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    // MARK: - Login and Signups
    
    @IBAction func loginUdacity(sender: UIButton) {
        
        UdacityClient.sharedInstance().createSessionWithUdacity(emailTextField.text, password: passwordTextField.text) { userId, errorString in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.errorAlert("Couldn't login to Udacity account", errorMessage: errorString!)
                }                
            } else {
                if let userId = userId {
                    self.initUserData(userId)
                }
            }
        }
    }
    
    @IBAction func loginFacebook(sender: UIButton) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            println("FBSDK current access token: \(FBSDKAccessToken.currentAccessToken())")
        } else {
            FBSDKLoginManager().logInWithReadPermissions(["public_profile"]) {result, error in
                if error != nil {
                    println("error: \(error)")
                } else if result.isCancelled {
                    println("login cancelled: \(result.isCancelled)")
                } else {
                    println("result: \(result.grantedPermissions)")
                }
            }
        }
    }
    
    func loginFacebookComplete() {
        if FBSDKAccessToken.currentAccessToken() != nil {
//            println("FBSDK current access token: \(FBSDKAccessToken.currentAccessToken().tokenString)")
            
            UdacityClient.sharedInstance().createSessionWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString) { userId, errorString in
                if errorString != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        // since there was an error getting user info from Udacity using Facebook token,
                        // logout the current user from Facebook
                        FBSDKLoginManager().logOut()
                        self.errorAlert("Couldn't complete Facebook/Udactiy handshake", errorMessage: errorString! + "Please login via Udacity account")
                    }
                } else {
                    if let userId = userId {
                        self.initUserData(userId)
                    }
                }
            }
        }
    }
    
    private func initUserData(userId: String) {
        UdacityClient.sharedInstance().getUserData(userId) { firstName, lastName, errorString in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.errorAlert("Couldn't get user info from Udacity", errorMessage: errorString!)
                }
            } else {
                User.currentUser.userId = userId
                User.currentUser.firstName = firstName
                User.currentUser.lastName = lastName
                
//                ParseClient.sharedInstance().queryStudentLocation(userId)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("StudentLocationsSegue", sender: self)
                }
                
            }
        }
    }
    
    @IBAction func signupUdacity(sender: UIButton) {
        
    }
    
    // MARK: - Alert
    func errorAlert(errorTitle: String, errorMessage: String) {
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Segue
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "StudentLocationsSegue" {
//            // prep code if any
//        }
//    }

    // MARK: - Text Field Delegates
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    // MARK: - Keyboard
    
    // Editing begain, slide view up
    func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y >= 0 {
            // divide by 3 to shift 33% of the view in relation to the keyboard
            self.view.frame.origin.y -= getKeyboardHeight(notification)  / 3
        }
    }
    
    // Editing ended, slide view down
    func keyboardWillHide(notification: NSNotificationCenter) {
        self.view.frame.origin.y = 0
    }
    
    private func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    private func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
}
