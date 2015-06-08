//
//  UdacityClient.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/6/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class UdacityClient: CommonAPI {
    
    override init() {
        super.init()
        super.skipResponseDataLength = 5
    }
    
    private struct Constants {
        static let baseURL = "https://www.udacity.com/api"
    }
    
    private struct Methods {
        static let session = Constants.baseURL + "/session"
        static let publicUserData = Constants.baseURL + "/users"
    }
        
    func createSessionWithUdacity(username: String, password: String, completionHandler: (userId: String?, errorString: String?) -> Void) {
        let httpBodyParams = [
            "udacity": ["username": username, "password": password]
        ]
        httpPost(Methods.session, httpBodyParams: httpBodyParams) { result, error in
            if error != nil {
                completionHandler(userId: nil, errorString: error?.localizedDescription)
            } else {
                if let account = result["account"] as? NSDictionary {
                    if let key = account["key"] as? String {
                        completionHandler(userId: key, errorString: nil)
                    } else {
                        completionHandler(userId: nil, errorString: "An unknown error occured")
                    }
                } else if let error = result["error"] as? String {
                    completionHandler(userId: nil, errorString: error)
                } else {
                    completionHandler(userId: nil, errorString: "An unknown error occured")
                }
            }
        }
    }
    
    func createSessionWithFacebook() {
        
    }
    
    func getUserData(userId: String, completionHandler: (firstName: String?, lastName: String?, errorString: String?) -> Void) {
        let url = Methods.publicUserData + "/" + userId
        httpGet(url) { result, error in
            if error != nil {
                completionHandler(firstName: nil, lastName: nil, errorString: error?.localizedDescription)
            } else {
                if let user = result["user"] as? NSDictionary {
                    if let firstName = user["first_name"] as? String {
                        if let lastName = user["last_name"] as? String {
                            completionHandler(firstName: firstName, lastName: lastName, errorString: nil)
                        } else {
                            completionHandler(firstName: nil, lastName: nil, errorString: "An unknown error occured")
                        }
                    } else {
                        completionHandler(firstName: nil, lastName: nil, errorString: "An unknown error occured")
                    }
                } else if let error = result["error"] as? String {
                    completionHandler(firstName: nil, lastName: nil, errorString: error)
                } else {
                    completionHandler(firstName: nil, lastName: nil, errorString: "An unknown error occured")
                }
            }
        }
    }
    
    static func sharedInstance() -> UdacityClient {
        let sharedInstance = UdacityClient()
        return sharedInstance
    }
}