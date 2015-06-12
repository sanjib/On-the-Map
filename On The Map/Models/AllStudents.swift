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
    
    static func addStudent(student: Student) {
        collection.append(student)
    }
    
    static func reset() {
        collection = [Student]()
    }
}