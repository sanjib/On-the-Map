//
//  StudentLocationsTableViewController.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/9/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class StudentLocationsTableViewController: UITableViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        // reset students and reload the table for an empty view to show the activityIndicator
        // (otherwise it's not shown since the table is already populated)
        AllStudents.reset()
        tableView.reloadData()
        
        activityIndicator.startAnimating()
        
        AllStudents.reload() { errorString in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.errorAlert("Couldn't get student locations", errorMessage: errorString!)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return AllStudents.collection.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell", forIndexPath: indexPath) as! UITableViewCell

        let student = AllStudents.collection[indexPath.row] as Student
        cell.textLabel?.text = student.firstName! + " " + student.lastName!
        cell.detailTextLabel?.text = student.link
        cell.imageView?.frame.size.width -= 20.0

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = AllStudents.collection[indexPath.row] as Student        
        if let urlString = student.link {
            if let url = NSURL(string: urlString) {
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
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
