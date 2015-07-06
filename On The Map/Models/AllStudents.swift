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
    
    static func reload(completionHandler: (errorString: String?) -> Void) {        
        ParseClient.sharedInstance().getStudentLocations() { students, errorString in
            if errorString != nil {
                completionHandler(errorString: errorString)
            } else {
                self.reset()
                self.collection = students!
                self.sortByFirstName()
                completionHandler(errorString: nil)
            }
        }
    }
    
    static func addStudent(student: Student) {
        collection.append(student)
        sortByFirstName()
    }
    
    static func reset() {
        collection = [Student]()
    }
    
    private static func sortByFirstName() {
        collection.sort({ $0.firstName < $1.firstName })
    }
}