//
//  LoginViewController.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/6/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // For tracking view slides
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Login and Signups
    
    @IBAction func loginUdacity(sender: UIButton) {
        
        UdacityClient.sharedInstance().createSessionWithUdacity(emailTextField.text, password: passwordTextField.text) { userId, errorString in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.errorAlert(errorString!)
                }                
            } else {
                if let userId = userId {
                    UdacityClient.sharedInstance().getUserData(userId) { firstName, lastName, errorString in
                        if errorString != nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.errorAlert(errorString!)
                            }
                        } else {
                            println("userId: \(userId)")
                            println("firstName: \(firstName)")
                            println("lastName: \(lastName)")
                        }

                    }
                }
            }
        }
    }
    
    @IBAction func loginFacebook(sender: UIButton) {
        
    }
    
    @IBAction func signupUdacity(sender: UIButton) {
        
    }
    
    // MARK: - Alert
    func errorAlert(errorString: String) {
        let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
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
