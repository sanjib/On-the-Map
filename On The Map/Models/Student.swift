//
//  Student.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/10/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class Student {
    var userId: String? = nil
    var objectId: String? = nil
    
    var firstName: String? = nil
    var lastName: String? = nil
    var link: String? = nil
    
    var imageData: NSData? = nil
    var isoCountryCode: String? = nil
    
    var locationName: String? = nil
    var latitude: Float? = nil
    var longitude: Float? = nil
    
    var annotation: StudentAnnotation? {
        get {
            if latitude != nil && longitude != nil {
                var aFirstName = ""
                if firstName != nil {
                    aFirstName = firstName!
                }
                var aLastName = ""
                if lastName != nil {
                    aLastName = lastName!
                }
                var aLink = ""
                if link != nil {
                    aLink = link!
                }
                return StudentAnnotation(
                    title: aFirstName + aLastName,
                    subtitle: aLink,
                    latitude: latitude!,
                    longitude: longitude!)
            } else {
                return nil
            }
        }
    }
}