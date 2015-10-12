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
        static let updateStudentLocation = Constants.baseURL + "/StudentLocation/{objectId}"
    }
    
    private struct MethodKeys {
        static let objectId = "objectId"
    }
    
    func getStudentLocations(completionHandler: (students: [Student]?, errorString: String?) -> Void) {
        let methodParams = [
            "limit": 1000
        ]
        let url = Methods.studentLocation + methodParamsFromDictionary(methodParams)
        
        httpGet(url) { result, error in
            if error != nil {
                completionHandler(students: nil, errorString: error?.localizedDescription)
                print(error)
            } else {
                if let studentResults = result["results"] as? NSArray {
                    var allStudents = [Student]()
                    for studentResult in studentResults {
                        let student = Student(jsonData: studentResult as? NSDictionary)
                        
                        // Check for duplicate student ID
                        if allStudents.filter({$0.userId == student.userId}).first != nil {
                            continue
                        } else {                            
                            allStudents.append(student)
                        }
                    }
                    completionHandler(students: allStudents, errorString: nil)
                }
            }
        }
    }
    
    func queryStudentLocation(userId: String, completionHandler: (student: Student?, errorString: String?) -> Void) {
        let methodParams = [
            "where": "{\"uniqueKey\":\"\(userId)\"}"
        ]
        let url = Methods.studentLocation + methodParamsFromDictionary(methodParams)
        httpGet(url) { result, error in
            if error != nil {
                completionHandler(student: nil, errorString: error?.localizedDescription)
            } else {
                if let studentResults = result["results"] as? NSArray {
                    if let studentResult = studentResults.firstObject as? NSDictionary {
                        let student = Student(jsonData: studentResult)
                        completionHandler(student: student, errorString: nil)
                    }
                }
            }
        }
    }
    
    func addStudentLocation(student: Student, completionHandler: (objectId: String?, errorString: String?) -> Void) {
        let url = Methods.studentLocation
        let httpBodyParams: [String:AnyObject] = [
            "uniqueKey": student.userId as! AnyObject,
            "firstName": student.firstName as! AnyObject,
            "lastName": student.lastName as! AnyObject,
            "mapString": student.locationName as! AnyObject,
            "mediaURL": student.link as! AnyObject,
            "latitude": student.latitude as! AnyObject,
            "longitude": student.longitude as! AnyObject
        ]
        httpPost(url, httpBodyParams: httpBodyParams) { result, error in
            if error != nil {
                completionHandler(objectId: nil, errorString: error?.localizedDescription)
            } else {
                if let objectId = result["objectId"] as? String {
                    completionHandler(objectId: objectId, errorString: nil)
                }
            }
        }
    }
    
    func updateStudentLocation(student: Student, completionHandler: (errorString: String?) -> Void) {
        let url = methodKeySubstitute(Methods.updateStudentLocation, key: MethodKeys.objectId, value: student.objectId!)!
        let httpBodyParams: [String:AnyObject] = [
            "uniqueKey": student.userId as! AnyObject,
            "firstName": student.firstName as! AnyObject,
            "lastName": student.lastName as! AnyObject,
            "mapString": student.locationName as! AnyObject,
            "mediaURL": student.link as! AnyObject,
            "latitude": student.latitude as! AnyObject,
            "longitude": student.longitude as! AnyObject
        ]
        httpPut(url, httpBodyParams: httpBodyParams) { result, error in
            if error != nil {
                completionHandler(errorString: error?.localizedDescription)
            } else {
                completionHandler(errorString: nil)
            }
        }
    }
    
    static func sharedInstance() -> ParseClient {
        let sharedInstance = ParseClient()
        return sharedInstance
    }
}