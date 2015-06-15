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
    // Layout properties
    let minimumSpacingBetweenCells = 5
    let cellsPerRowInPortraitMode = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if AllStudents.collection.count == 0 {
            reloadStudentLocations()
        }
    }
    
    func reloadStudentLocations() {
        AllStudents.reload() { errorString in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.errorAlert("Couldn't get student locations", errorMessage: errorString!)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView?.reloadData()
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
        println(AllStudents.collection.count)
        return AllStudents.collection.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> StudentProfileCollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StudentProfileCollectionViewCell
    
        let student = AllStudents.collection[indexPath.row]
        if student.imageURL == nil {
            UdacityClient.sharedInstance().getUserPhoto(student) { imageURL in
                if imageURL != nil {
                    student.imageURL = imageURL
                    let urlString = "https:" + imageURL!
                    if let url = NSURL(string: urlString) {
                        println("will get \(urlString)")
                        student.imageData = NSData(contentsOfURL: url)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        }
                    } else {
                        student.imageData = NSData(contentsOfFile: "no-student-image")
                    }
                }
            }
        }
        
        // Configure the cell
        if let imageData = student.imageData {
            cell.studentImageView.image = UIImage(data: imageData)
        } else {
            cell.studentImageView.image = UIImage(named: "no-student-image")
        }
        cell.studentLabel.text = student.firstName
        
        if let studentLocation = student.annotation?.coordinate {
            let location = CLLocation(latitude: studentLocation.latitude, longitude: studentLocation.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if error != nil {
                    
                } else {
                    if let placemark = placemarks.first as? CLPlacemark {
                        println(placemark.ISOcountryCode)
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
