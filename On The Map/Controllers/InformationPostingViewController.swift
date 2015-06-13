//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/13/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var findOnTheMapContainerView: UIView!
    @IBOutlet weak var submitInformationContainerView: UIView!

    var tapGestureRecognizer: UITapGestureRecognizer? = nil
    var currentTextFieldBeingEdited = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        linkTextField.delegate = self
        
        locationTextField.tag = 1
        linkTextField.tag = 2
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTap:")
        tapGestureRecognizer?.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGestureRecognizer!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        findOnTheMapContainerView.hidden = false
        submitInformationContainerView.hidden = true
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - Button actions
    
    
    @IBAction func cancelFromLocationView(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelFromLinkView(sender: UIButton) {
        findOnTheMapContainerView.hidden = false
        submitInformationContainerView.hidden = true
    }
    
    @IBAction func findOnTheMap(sender: UIButton) {
        findOnTheMapContainerView.hidden = true
        submitInformationContainerView.hidden = false
    }
    
    @IBAction func submitInformation(sender: UIButton) {
        // on success: reload parent vc (table or map)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    // MARK: - Text field delegates
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        println("textfield tag : \(textField.tag)")
        if textField.tag == 1 {
            currentTextFieldBeingEdited = "location"
        } else if textField.tag == 2 {
            currentTextFieldBeingEdited = "link"
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func singleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Keyboard
    
    // Editing begain, slide view up
    func keyboardWillShow(notification: NSNotification) {
        println(currentTextFieldBeingEdited)
        if currentTextFieldBeingEdited == "location" {
            if self.view.frame.origin.y >= 0 {
                // divide by 3 to shift 33% of the view in relation to the keyboard
                self.view.frame.origin.y -= getKeyboardHeight(notification)  / 3
            }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
