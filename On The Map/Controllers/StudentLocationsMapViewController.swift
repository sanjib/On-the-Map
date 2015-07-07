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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshView", name: "refreshMapView", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if AllStudents.reloadInProgress == false && AllStudents.collection.count == 0 {
            reloadStudentLocations()
        } else if AllStudents.reloadInProgress == true {
            reloadInProgressView()
        }
    }
    
    func refreshView() {
        self.activityIndicator.stopAnimating()
        for student in AllStudents.collection {
            self.studentLocationsMapView.addAnnotation(student.annotation)
        }
        if let rightBarButtonItems = self.navigationController?.navigationBar.items.last?.rightBarButtonItems as? [UIBarButtonItem] {
            rightBarButtonItems.first?.enabled = true
        }
    }
    
    func refreshViewAndNotify() {
        refreshView()
        // refresh the view in the other 2 view controllers
        NSNotificationCenter.defaultCenter().postNotificationName("refreshTableView", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("refreshCollectionView", object: nil)
        
    }
    
    func reloadInProgressView() {
        if let rightBarButtonItems = self.navigationController?.navigationBar.items.last?.rightBarButtonItems as? [UIBarButtonItem] {
            rightBarButtonItems.first?.enabled = false
        }
        
        studentLocationsMapView.removeAnnotations(studentLocationsMapView.annotations)
        activityIndicator.startAnimating()
    }

    // MARK: - Student Locations
    
    func reloadStudentLocations() {
        if AllStudents.reloadInProgress == false {
            AllStudents.reload() { errorString in
                if errorString != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.stopAnimating()
                        ErrorAlert.create("Failed Getting Student Locations", errorMessage: errorString!, viewController: self)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshViewAndNotify()
                    }
                }
            }
        }
        reloadInProgressView()
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
                ErrorAlert.create("Invalid Student Link", errorMessage: "The link provided by the student is not a valid URL: \(urlString)", viewController: self)
            }
        } else {
            ErrorAlert.create("Invalid Student Link", errorMessage: "The student did not provide a link.", viewController: self)
        }
    }

}
