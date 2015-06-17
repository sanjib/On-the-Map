//
//  StudentLocationsMapViewController.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/10/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationsMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var studentLocationsMapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        studentLocationsMapView.delegate = self
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if AllStudents.collection.count == 0 {
            reloadStudentLocations()
        }
    }
    
    // MARK: - Student Locations
    func reloadStudentLocations() {
        self.activityIndicator.startAnimating()
        
        AllStudents.reload() { errorString in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.errorAlert("Couldn't get student locations", errorMessage: errorString!)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentLocationsMapView.removeAnnotations(self.studentLocationsMapView.annotations)
                    for student in AllStudents.collection {
                        self.studentLocationsMapView.addAnnotation(student.annotation)
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    // MARK: - Map view delegates
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? StudentAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let urlString = view.annotation.subtitle
        if urlString != "" {
            if let url = NSURL(string: urlString!) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                errorAlert("Student Link cannot be opened", errorMessage: "The link provided by the student is not a valid URL: \(urlString)")
            }
        } else {
            errorAlert("Student Link cannot be opened", errorMessage: "The student did not provide a link")
        }
    }
    
    // MARK: - Alert
    func errorAlert(errorTitle: String, errorMessage: String) {
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
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
