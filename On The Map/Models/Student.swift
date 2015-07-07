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
    var imageFetchInProgress: Bool = false
    var isoCountryCode: String? = nil
    
    var locationName: String? = nil
    var latitude: Float? = nil
    var longitude: Float? = nil
    
    init(jsonData: NSDictionary?) {
        if let jsonData = jsonData {
            if let userId = jsonData["uniqueKey"] as? String {
                self.userId = userId
            }
            if let objectId = jsonData["objectId"] as? String {
                self.objectId = objectId
            }
            if let firstName = jsonData["firstName"] as? String {
                self.firstName = firstName
            }
            if let lastName = jsonData["lastName"] as? String {
                self.lastName = lastName
            }
            if let link = jsonData["mediaURL"] as? String {
                self.link = link
            }
            if let locationName = jsonData["mapString"] as? String {
                self.locationName = locationName
            }
            if let latitude = jsonData["latitude"] as? Float {
                self.latitude = latitude
            }
            if let longitude = jsonData["longitude"] as? Float {
                self.longitude = longitude
            }
        }
    }
    
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