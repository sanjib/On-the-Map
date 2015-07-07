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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshView", name: "refreshTableView", object: nil)
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
        self.tableView.reloadData()
        if let rightBarButtonItems = self.navigationController?.navigationBar.items.last?.rightBarButtonItems as? [UIBarButtonItem] {
            rightBarButtonItems.first?.enabled = true
        }
    }
    
    func refreshViewAndNotify() {
        refreshView()
        
        // refresh the view in the other 2 view controllers
        NSNotificationCenter.defaultCenter().postNotificationName("refreshMapView", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("refreshCollectionView", object: nil)
    }
    
    func reloadInProgressView() {
        activityIndicator.startAnimating()
        tableView.reloadData()
        if let rightBarButtonItems = self.navigationController?.navigationBar.items.last?.rightBarButtonItems as? [UIBarButtonItem] {
            rightBarButtonItems.first?.enabled = false
        }
    }
    
    // MARK: - Student Locations
    
    func reloadStudentLocations() {
        // reset students and reload the table for an empty view to show the activityIndicator
        // (otherwise it's not shown since the table is already populated)
        
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
                ErrorAlert.create("Invalid Student Link", errorMessage: "The link provided by the student is not a valid URL: \(urlString)", viewController: self)
            }
        } else {
            ErrorAlert.create("Invalid Student Link", errorMessage: "The student did not provide a link.", viewController: self)
        }
    }
}
