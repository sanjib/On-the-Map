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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
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
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return AllStudents.collection.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StudentProfileCollectionViewCell
        cell.activityIndicator.stopAnimating()
        
        let student = AllStudents.collection[indexPath.row]
        
        // keep track of image fetch in progress because the cell may be dequed
        if student.imageFetchInProgress {
            cell.activityIndicator.startAnimating()
        } else {
            cell.activityIndicator.stopAnimating()
        }
        
        cell.studentLabel.text = student.firstName
        
        // Configure the cell
        if let imageData = student.imageData {
            cell.studentImageView.image = UIImage(data: imageData)
        } else {
            // immediately set a no-student-image first, then if image url exists fetch the image
            let noStudentImage = UIImage(named: "no-student-image")
            student.imageData = NSData(data: UIImagePNGRepresentation(noStudentImage))
            cell.studentImageView.image = noStudentImage
            
            student.imageFetchInProgress = true
            cell.activityIndicator.startAnimating()
            UdacityClient.sharedInstance().getUserPhoto(student) { imageURL in
                if imageURL != nil {
                    if let url = NSURL(string: "https:" + imageURL!) {
                        student.imageData = NSData(contentsOfURL: url)
                        student.imageFetchInProgress = false
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.activityIndicator.stopAnimating()
                            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        }
                    } else {
                        student.imageFetchInProgress = false
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.activityIndicator.stopAnimating()
                        }
                    }
                } else {
                    student.imageFetchInProgress = false
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.activityIndicator.stopAnimating()
                    }
                }
            }
        }
        
        if let isoCountryCode = student.isoCountryCode {
            if let flagImage = UIImage(named: isoCountryCode.lowercaseString) {
                cell.flagImageView.image = flagImage
            }
        } else {
            if let studentLocation = student.annotation?.coordinate {
                let location = CLLocation(latitude: studentLocation.latitude, longitude: studentLocation.longitude)
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    if error != nil {

                    } else {
                        if let placemark = placemarks.first as? CLPlacemark {
                            student.isoCountryCode = placemark.ISOcountryCode
                            dispatch_async(dispatch_get_main_queue()) {
                                self.collectionView?.reloadItemsAtIndexPaths([indexPath])
//                                if let flagImage = UIImage(named: student.isoCountryCode!.lowercaseString) {
//                                    cell.flagImageView.image = flagImage
//                                }
                            }
                        }
                    }
                }
            }
        }
    
        return cell
    }
    


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
