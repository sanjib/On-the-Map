//
//  StudentLocationsCollectionViewController.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/14/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import MapKit

let reuseIdentifier = "StudentCollectionViewCell"

class StudentLocationsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let noStudentImage = UIImage(named: "no-student-image")
    private let noStudentImageData = NSData(data: UIImagePNGRepresentation(UIImage(named: "no-student-image")))
    
    // Layout properties
    let minimumSpacingBetweenCells = 5
    let cellsPerRowInPortraitMode = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.stopAnimating()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if AllStudents.collection.count == 0 {
            reloadStudentLocations()
        }
    }
    
    func reloadStudentLocations() {
        activityIndicator.startAnimating()
        
        AllStudents.reload() { errorString in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.errorAlert("Couldn't get student locations", errorMessage: errorString!)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView?.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    // MARK: - Alert
    func errorAlert(errorTitle: String, errorMessage: String) {
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Use width in portrait mode; height in landscape
        let deviceOrientation = UIDevice.currentDevice().orientation
        var widthForCollection: CGFloat!
        if (deviceOrientation == UIDeviceOrientation.Portrait) || (deviceOrientation == UIDeviceOrientation.PortraitUpsideDown) {
            widthForCollection = self.view.frame.width
        } else {
            widthForCollection = self.view.frame.height
        }
        
        // To determine width of a cell we divide frame width by cells per row
        // Then compensate it by subtracting minimum spacing between cells
        // The last cell doesn't need compensation for spacing
        let width = Float(widthForCollection / CGFloat(cellsPerRowInPortraitMode)) -
            Float(minimumSpacingBetweenCells - (minimumSpacingBetweenCells / cellsPerRowInPortraitMode))
        let height = width
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(minimumSpacingBetweenCells)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(minimumSpacingBetweenCells)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AllStudents.collection.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StudentProfileCollectionViewCell
        
        let student = AllStudents.collection[indexPath.row]
        cell.studentLabel.text = student.firstName
        
        // Keep track of image fetch in progress because the cell may be dequed
        if student.imageFetchInProgress {
            cell.activityIndicator.startAnimating()
        } else {
            cell.activityIndicator.stopAnimating()
        }

        // Student images
        if let imageData = student.imageData {
            cell.studentImageView.image = UIImage(data: imageData)
        } else {
            // immediately set a no-student-image first, then if image url exists fetch the image
            student.imageData = noStudentImageData
            cell.studentImageView.image = noStudentImage

            student.imageFetchInProgress = true
            cell.activityIndicator.startAnimating()
            UdacityClient.sharedInstance().getUserPhoto(student) { imageURL in
                if imageURL != nil {
                    if let url = NSURL(string: "https:" + imageURL!) {
                        student.imageData = NSData(contentsOfURL: url)
                        student.imageFetchInProgress = false
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        }
                    } else {
                        student.imageFetchInProgress = false
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        }
                    }
                } else {
                    student.imageFetchInProgress = false
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                    }
                }
            }
        }
        
        // Flags
        if let isoCountryCode = student.isoCountryCode {
            if let flagImage = UIImage(named: isoCountryCode.lowercaseString) {
                cell.flagImageView.layer.borderWidth = 1.0
                cell.flagImageView.image = flagImage
            } else {
                cell.flagImageView.layer.borderWidth = 0
                cell.flagImageView.image = nil
            }
        } else {
            if let studentLocation = student.annotation?.coordinate {
                let location = CLLocation(latitude: studentLocation.latitude, longitude: studentLocation.longitude)
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    if error != nil {
                        // Silently fail because there is no need to alert user that 
                        // we couldn't get the country ISO code for displaying flag
                    } else {
                        if let placemark = placemarks.first as? CLPlacemark {
                            student.isoCountryCode = placemark.ISOcountryCode
                            dispatch_async(dispatch_get_main_queue()) {
                                self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                            }
                        }
                    }
                }
            }
        }
    
        return cell
    }

}
