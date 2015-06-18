//
//  User.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/10/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class User {
//    var objectId: String? = nil
    static var currentUser = Student()
    
    static func reset() {
        currentUser = Student()
    }
}