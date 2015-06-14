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
        static let studentLocation       = Constants.baseURL + "/StudentLocation"
//        static let queryStudentLocation  = Constants.baseURL + "/StudentLocation?where={\"uniqueKey\":\"userId\"}"
//        static let updateStudentLocation = Constants.baseURL + "/StudentLocation/{objectId}"
    }
    
    func getStudentLocations(completionHandler: (students: [Student]?, errorString: String?) -> Void) {
        let methodParams = [
            "limit": 1000
        ]
        let url = Methods.studentLocation + methodParamsFromDictionary(methodParams)
        
        httpGet(url) { result, error in
            if error != nil {
                completionHandler(students: nil, errorString: error?.localizedDescription)
                println(error)
            } else {
//                println(result)
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
    
    func queryStudentLocation(userId: String) {
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(userId)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { /* Handle error */ return }
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    static func sharedInstance() -> ParseClient {
        let sharedInstance = ParseClient()
        return sharedInstance
    }
}