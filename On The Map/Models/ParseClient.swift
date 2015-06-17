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
                println(error)
            } else {
//                println(result)
                if let studentResults = result["results"] as? NSArray {
                    var allStudents = [Student]()
                    for studentResult in studentResults {
                        let student = self.parseJSONStudentResult(studentResult as! NSDictionary)
                        if let duplicateStudentById =  allStudents.filter({$0.userId == student.userId}).first {
                            continue
                        } else {                            
                            allStudents.append(student)
                            
                            
//                            if let duplicateStudentByName = allStudents.filter({$0.firstName! + $0.lastName! == student.firstName! + student.lastName!}).first {
//                                continue
//                            } else {
//                                allStudents.append(student)
//                            }
                        }
//                        if duplicateStudent != nil {
//                            if let duplicatedStudentUpdatedAt = duplicateStudent?.updatedAt {
//                                if student.updatedAt?.compare(duplicatedStudentUpdatedAt) == NSComparisonResult.OrderedDescending  {
//                                    println("will replace: old- \(duplicateStudent?.updatedAt) with new- \(student.updatedAt)")
                                    
//                                }
//                            }
//                            
//                        } else {
                        
//                        }
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
                        let student = self.parseJSONStudentResult(studentResult)
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
        
//        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
//        request.HTTPMethod = "POST"
//        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
//        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".dataUsingEncoding(NSUTF8StringEncoding)
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(request) { data, response, error in
//            if error != nil { // Handle error
//                return
//            }
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
//        }
//        task.resume()
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
    
    private func parseJSONStudentResult(studentResult: NSDictionary) -> Student {
        let student = Student()
        if let userId = studentResult["uniqueKey"] as? String {
            student.userId = userId
        }
        if let objectId = studentResult["objectId"] as? String {
            student.objectId = objectId
        }
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
        
        // sometimes multiple locations exist for a student
        // in the future we may want to check the latest updatedAt
        // and replace that object
        if let updatedAt = studentResult["updatedAt"] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
            let date = dateFormatter.dateFromString(updatedAt)
            student.updatedAt = date
        }
        return student
    }
    
    static func sharedInstance() -> ParseClient {
        let sharedInstance = ParseClient()
        return sharedInstance
    }
}