//
//  Student.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/10/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class Student {
    var firstName: String? = nil
    var lastName: String? = nil
    var locationName: String? = nil
    var latitude: Float? = nil
    var longitude: Float? = nil
    var link: String? = nil
    var annotation: StudentAnnotation? {
        get {
            if latitude != nil && longitude != nil {
                return StudentAnnotation(
                    title: "\(firstName) \(lastName)",
                    subtitle: "\(link)",
                    latitude: latitude!,
                    longitude: longitude!)
            } else {
                return nil
            }
        }
    }
}