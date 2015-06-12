//
//  StudentLocationsMapViewController.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/10/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class StudentLocationsMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Student Locations
    func reloadStudentLocations() {
        println("reloading student locations in map vc")
        AllStudents.reset()
        ParseClient.sharedInstance().getStudentLocations() { students, error in
            if error != nil {
                
            } else {
                AllStudents.collection = students
                dispatch_async(dispatch_get_main_queue()) {

                }
            }
        }
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
