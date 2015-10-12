//
//  AllStudents.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/10/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class AllStudents: NSObject {
    static var collection = [Student]()
    static var reloadInProgress = false
    
    static func reload(completionHandler: (errorString: String?) -> Void) {
        reloadInProgress = true
        
        // Stop all NSURLSession tasks
        NSURLSession.sharedSession().getTasksWithCompletionHandler() { dataTasks, uploadTasks, downloadTasks in
            for dataTask in dataTasks {
                dataTask.cancel()
            }
        }
        NSURLSession.sharedSession().invalidateAndCancel()
        
        collection = [Student]()
        ParseClient.sharedInstance().getStudentLocations() { students, errorString in
            if errorString != nil {
                completionHandler(errorString: errorString)
            } else {
                self.collection = students!
                self.sortByFirstName()
                self.reloadInProgress = false
                completionHandler(errorString: nil)
            }
        }
    }
    
    static func addStudent(student: Student) {
        collection.append(student)
        sortByFirstName()
    }

    // Should be reset when user logs out
    static func reset() {
        collection = [Student]()
    }
    
    private static func sortByFirstName() {
        collection.sortInPlace({ $0.firstName < $1.firstName })
    }
}