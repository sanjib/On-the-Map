//
//  ParseClient.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/6/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class ParseClient {
    private struct Constants {
        static let baseURL = "https://www.udacity.com/api"
    }
    
    private struct Methods {
        static let session = Constants.baseURL + "/session"
        static let publicUserData = Constants.baseURL + "/api/users/{id}"
    }
    
}