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
    
    func getStudentLocations(completionHandler: (students: [Student], errorString: String?) -> Void) {
        httpGet(Methods.getStudentLocations) { result, error in
            if error != nil {
//                completionHandler(firstName: nil, lastName: nil, errorString: error?.localizedDescription)
                println(error)
            } else {
                if let studentsJSON = result["results"] as? NSArray {
//                    println(studentsJSON)
                    var allStudents = [Student]()
                    for studentJSON in studentsJSON {
                        let student = Student()
                        if let firstName = studentJSON["firstName"] as? String {
                            student.firstName = firstName
                        }
                        if let lastName = studentJSON["lastName"] as? String {
                            student.lastName = lastName
                        }
                        if let link = studentJSON["mediaURL"] as? String {
                            student.link = link
                        }
                        allStudents.append(student)
                    }
                    completionHandler(students: allStudents, errorString: nil)
                }
//                if let user = result["user"] as? NSDictionary {
//                    if let firstName = user["first_name"] as? String {
//                        if let lastName = user["last_name"] as? String {
//                            completionHandler(firstName: firstName, lastName: lastName, errorString: nil)
//                        } else {
//                            completionHandler(firstName: nil, lastName: nil, errorString: "An unknown error occured")
//                        }
//                    } else {
//                        completionHandler(firstName: nil, lastName: nil, errorString: "An unknown error occured")
//                    }
//                } else if let error = result["error"] as? String {
//                    completionHandler(firstName: nil, lastName: nil, errorString: error)
//                } else {
//                    completionHandler(firstName: nil, lastName: nil, errorString: "An unknown error occured")
//                }
//                println(result)
            }
        }
    }
    
    static func sharedInstance() -> ParseClient {
        let sharedInstance = ParseClient()
        return sharedInstance
    }
}