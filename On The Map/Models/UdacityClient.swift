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
    
    private struct ErrorMessages {
        static let parameter = [
            "udacity.username": "Please type your Udacity username.",
            "udacity.password": "Please type your Udacity password."
        ]
    }
    
    private struct Methods {
        static let session = Constants.baseURL + "/session"
        static let publicUserData = Constants.baseURL + "/users/{user_id}"
    }
    
    private struct MethodKeys {
        static let userId = "user_id"
    }
        
    func createSessionWithUdacity(username: String, password: String, completionHandler: (userId: String?, errorString: String?) -> Void) {
        let url = Methods.session
        let httpBodyParams = [
            "udacity": ["username": username, "password": password]
        ]
        httpPost(url, httpBodyParams: httpBodyParams) { result, error in
            if error != nil {
                completionHandler(userId: nil, errorString: error?.localizedDescription)
            } else {
                if let account = result["account"] as? NSDictionary {
                    if let key = account["key"] as? String {
                        completionHandler(userId: key, errorString: nil)
                    } else {
                        completionHandler(userId: nil, errorString: "JSON key error: account not found.")
                    }
                } else if let error = result["error"] as? String {
                    if let errorParameter = result["parameter"] as? String {
                        if let errorParameterMessage = ErrorMessages.parameter[errorParameter] {
                            completionHandler(userId: nil, errorString: errorParameterMessage)
                        } else {
                            completionHandler(userId: nil, errorString: error)
                        }
                    }
                    completionHandler(userId: nil, errorString: error)
                } else {
                    completionHandler(userId: nil, errorString: "An error occured.")
                }
            }
        }
    }
    
    func createSessionWithFacebook(accessToken: String, completionHandler: (userId: String?, errorString: String?) -> Void) {
        let url = Methods.session
        let httpBodyParams = [
            "facebook_mobile": ["access_token": accessToken]
        ]
        httpPost(url, httpBodyParams: httpBodyParams) { result, error in
            if error != nil {
                completionHandler(userId: nil, errorString: error?.localizedDescription)
            } else {
                if let account = result["account"] as? NSDictionary {
                    if let key = account["key"] as? String {
                        completionHandler(userId: key, errorString: nil)
                    } else {
                        completionHandler(userId: nil, errorString: "JSON key error: account not found.")
                    }
                } else if let error = result["error"] as? String {
                    completionHandler(userId: nil, errorString: error)
                } else {
                    completionHandler(userId: nil, errorString: "An error occured")
                }
            }
        }
    }
    
    func getUserData(userId: String, completionHandler: (firstName: String?, lastName: String?, errorString: String?) -> Void) {
        let url = methodKeySubstitute(Methods.publicUserData, key: MethodKeys.userId, value: userId)
        httpGet(url!) { result, error in
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
    
    func getUserPhoto(student: Student, completionHandler: (imageURL: String?) -> Void) -> Void {
        if let userId = student.userId {
            if let url = methodKeySubstitute(Methods.publicUserData, key: MethodKeys.userId, value: userId) {
                httpGet(url) { result, error in
                    if error != nil {
                        completionHandler(imageURL: nil)
                    } else {
                        if let user = result["user"] as? NSDictionary {
                            if let image_url = user["_image_url"] as? String {
                                completionHandler(imageURL: image_url)
                            }
                        } else {
                            completionHandler(imageURL: nil)
                        }
                    }
                }
            }
        }
    }
    
    func logout(completionHandler: (success: Bool?, errorString: String?) -> Void) {
        let url = Methods.session
        httpDelete(url, cookieName: "XSRF-TOKEN") { result, error in
            if error != nil {
                completionHandler(success: nil, errorString: error?.localizedDescription)
            } else {
                if let session = result["session"] as? NSDictionary {
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: nil, errorString: "An unknown error occured.")
                }
            }
            
        }
    }
    
    static func sharedInstance() -> UdacityClient {
        let sharedInstance = UdacityClient()
        return sharedInstance
    }
}