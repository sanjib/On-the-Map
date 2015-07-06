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
    @IBOutlet weak var udacityLoginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var udacityLoginButton: RoundStyleButton!
    @IBOutlet weak var facebookLoginButton: RoundStyleButton!
    
    let udacityLoginButtonTitleNormal = "Login"
    let udacityLoginButtonTitleLoggingIn = "Logging in with Udacity..."
    let facebookLoginButtonTitleNormal = "Sign in with Facebook"
    let facebookLoginButtonTitleLoggingIn = "Signing in with Facebook..."
        
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        udacityLoginActivityIndicator.hidesWhenStopped = true
        facebookLoginActivityIndicator.hidesWhenStopped = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginFacebookComplete", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        udacityLoginIndicatorNormal()
        facebookLoginIndicatorNormal()
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
        udacityLoginIndicatorLoggingIn()
        
        UdacityClient.sharedInstance().createSessionWithUdacity(emailTextField.text, password: passwordTextField.text) { userId, errorString in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.udacityLoginIndicatorNormal()
                    ErrorAlert.create("Udacity Login Failed", errorMessage: errorString!, viewController: self)
                }
            } else {
                if let userId = userId {
                    self.initUserData(userId)
                }
            }
        }
    }
    
    @IBAction func loginFacebook(sender: UIButton) {
        if IJReachability.isConnectedToNetwork() == false {
            ErrorAlert.create("Facebook Login Failed", errorMessage: CommonAPI.ErrorMessages.noInternet, viewController: self)
            return
        }
        
        if FBSDKAccessToken.currentAccessToken() == nil {
            FBSDKLoginManager().logInWithReadPermissions(["public_profile"]) { result, error in
                if error != nil {
                    ErrorAlert.create("Facebook Login Failed", errorMessage: error.localizedDescription, viewController: self)
                } else if result.isCancelled {
                    ErrorAlert.create("Facebook Login Failed", errorMessage: "Login process was cancelled.", viewController: self)
                }
            }
        }
    }
    
    func loginFacebookComplete() {
        if FBSDKAccessToken.currentAccessToken() != nil {
            facebookLoginIndicatorLoggingIn()
            
            UdacityClient.sharedInstance().createSessionWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString) { userId, errorString in
                if errorString != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        // since there was an error getting user info from Udacity using Facebook token,
                        // logout the current user from Facebook
                        self.facebookLoginIndicatorNormal()
                        FBSDKLoginManager().logOut()
                        ErrorAlert.create("Facebook Login Failed", errorMessage: errorString! + " Please login via Udacity account.", viewController: self)
                    }
                } else {
                    if let userId = userId {
                        self.initUserData(userId)
                    }
                }
            }
        }
    }
    
    private func udacityLoginIndicatorNormal() {
        udacityLoginActivityIndicator.stopAnimating()
        view.userInteractionEnabled = true
        udacityLoginButton.setTitle(self.udacityLoginButtonTitleNormal, forState: .Normal)
    }
    
    private func udacityLoginIndicatorLoggingIn() {
        udacityLoginActivityIndicator.startAnimating()
        view.userInteractionEnabled = false
        udacityLoginButton.setTitle(udacityLoginButtonTitleLoggingIn, forState: .Normal)
    }
    
    private func facebookLoginIndicatorNormal() {
        facebookLoginActivityIndicator.stopAnimating()
        view.userInteractionEnabled = true
        facebookLoginButton.setTitle(self.facebookLoginButtonTitleNormal, forState: .Normal)
    }
    
    private func facebookLoginIndicatorLoggingIn() {
        facebookLoginActivityIndicator.startAnimating()
        view.userInteractionEnabled = false
        facebookLoginButton.setTitle(facebookLoginButtonTitleLoggingIn, forState: .Normal)
    }
    
    private func initUserData(userId: String) {
        UdacityClient.sharedInstance().getUserData(userId) { firstName, lastName, errorString in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    ErrorAlert.create("Failed Getting User Info", errorMessage: errorString!, viewController: self)
                }
            } else {
                User.currentUser.userId = userId
                User.currentUser.firstName = firstName
                User.currentUser.lastName = lastName
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.facebookLoginIndicatorNormal()
                    self.udacityLoginIndicatorNormal()
                    self.performSegueWithIdentifier("StudentLocationsSegue", sender: self)
                }
            }
        }
    }
    
    @IBAction func signupUdacity(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
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
