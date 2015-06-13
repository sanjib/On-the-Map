//
//  ParseClient.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/6/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class ParseClient: CommonAPI {

    override init() {
        super.init()
        super.additionalHTTPHeaderFields = [
            "X-Parse-Application-Id": Constants.parseApplicationId,
            "X-Parse-REST-API-Key": Constants.restApiKey
        ]
    }
    
    private struct Constants {
        static let baseURL = "https://api.parse.com/1/classes"
        static let parseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let restApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    private struct Methods {
        static let getStudentLocations   = Constants.baseURL + "/StudentLocation?limit=100"
        static let addStudentLocation    = Constants.baseURL + "/StudentLocation"
        static let queryStudentLocation  = Constants.baseURL + "/StudentLocation?where={\"uniqueKey\":\"userId\"}"
        static let updateStudentLocation = Constants.baseURL + "/StudentLocation/{objectId}"
    }
    
    func getStudentLocations(completionHandler: (students: [Student]?, errorString: String?) -> Void) {
        httpGet(Methods.getStudentLocations) { result, error in
            if error != nil {
                completionHandler(students: nil, errorString: error?.localizedDescription)
                println(error)
            } else {
                if let studentResults = result["results"] as? NSArray {
                    var allStudents = [Student]()
                    for studentResult in studentResults {
                        let student = Student()
                        if let firstName = studentResult["firstName"] as? String {
                            student.firstName = firstName
                        }
                        if let lastName = studentResult["lastName"] as? String {
                            student.lastName = lastName
                        }
                        if let link = studentResult["mediaURL"] as? String {
                            student.link = link
                        }
                        if let locationName = studentResult["mapString"] as? String {
                            student.locationName = locationName
                        }
                        if let latitude = studentResult["latitude"] as? Float {
                            student.latitude = latitude
                        }
                        if let longitude = studentResult["longitude"] as? Float {
                            student.longitude = longitude
                        }
                        
                        allStudents.append(student)
                    }
                    completionHandler(students: allStudents, errorString: nil)
                }
            }
        }
    }
    
    static func sharedInstance() -> ParseClient {
        let sharedInstance = ParseClient()
        return sharedInstance
    }
}