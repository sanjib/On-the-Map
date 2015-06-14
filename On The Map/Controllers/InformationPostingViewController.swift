//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/13/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var findOnTheMapContainerView: UIView!
    @IBOutlet weak var submitInformationContainerView: UIView!

    var tapGestureRecognizer: UITapGestureRecognizer? = nil
    private var currentTextFieldBeingEdited = ""
    private let student = Student()
    
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
        if locationTextField.text == "" {
            errorAlert("Empty Location", errorMessage: "Please type a location")
        } else {
            CLGeocoder().geocodeAddressString(locationTextField.text) { placemarks, error in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.errorAlert("Couldn't find location", errorMessage: error.localizedDescription)
                    }
                } else {
                    if placemarks.count == 1 {
                        for placemark in placemarks as! [CLPlacemark] {
                            dispatch_async(dispatch_get_main_queue()){
                                self.findOnTheMapContainerView.hidden = true
                                self.submitInformationContainerView.hidden = false
                                self.showStudentLocation(placemark.location)
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.errorAlert("Multiple locations found", errorMessage: "Please type a more specific location")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func submitInformation(sender: UIButton) {
        // if user objectId exists, update else add
        // on success: reload parent vc (table or map)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Map methods
    
    func showStudentLocation(location: CLLocation) {
        mapView.removeAnnotations(mapView.annotations)
        
        student.latitude = Float(location.coordinate.latitude)
        student.longitude = Float(location.coordinate.longitude)
        if student.annotation != nil {
            mapView.showAnnotations([student.annotation!], animated: true)
        }
    }
    
    // MARK: - Alert
    func errorAlert(errorTitle: String, errorMessage: String) {
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }


    // MARK: - Text field delegates
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
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

}
