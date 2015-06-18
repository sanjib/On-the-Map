//
//  CommonAPIClient.swift
//  On The Map
//
//  Created by Sanjib Ahmad on 6/6/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import Foundation

class CommonAPI {
    let session = NSURLSession.sharedSession()
    
    // can be overridden by a subclass
    var skipResponseDataLength: Int? = nil
    var additionalHTTPHeaderFields: [String:String]? = nil
    
    func httpGet(url: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        if let additionalHTTPHeaderFields = self.additionalHTTPHeaderFields {
            for (httpHeaderField, value) in additionalHTTPHeaderFields {
                request.addValue(value, forHTTPHeaderField: httpHeaderField)
            }
        }
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
                return
            }            
            self.parseJSONData(data, completionHandler: completionHandler)
        }
        task.resume()
    }
    
    func httpPost(url: String, httpBodyParams: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        if let additionalHTTPHeaderFields = self.additionalHTTPHeaderFields {
            for (httpHeaderField, value) in additionalHTTPHeaderFields {
                request.addValue(value, forHTTPHeaderField: httpHeaderField)
            }
        }
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(httpBodyParams, options: nil, error: nil)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
                return
            }
            self.parseJSONData(data, completionHandler: completionHandler)
        }
        task.resume()
    }
    
    func httpPut(url: String, httpBodyParams: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        if let additionalHTTPHeaderFields = self.additionalHTTPHeaderFields {
            for (httpHeaderField, value) in additionalHTTPHeaderFields {
                request.addValue(value, forHTTPHeaderField: httpHeaderField)
            }
        }
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(httpBodyParams, options: nil, error: nil)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
                return
            }
            self.parseJSONData(data, completionHandler: completionHandler)
        }
        task.resume()
    }
    
    func httpDelete(url: String, cookieName: String?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        if let additionalHTTPHeaderFields = self.additionalHTTPHeaderFields {
            for (httpHeaderField, value) in additionalHTTPHeaderFields {
                request.addValue(value, forHTTPHeaderField: httpHeaderField)
            }
        }
        request.HTTPMethod = "DELETE"

        if let cookieName = cookieName {
            var cookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for sharedCookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
                if sharedCookie.name == cookieName { cookie = sharedCookie }
            }
            if let cookie = cookie {
                request.addValue(cookie.value!, forHTTPHeaderField: cookieName)
            }
        }

        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
                return
            }
            self.parseJSONData(data, completionHandler: completionHandler)
        }
        task.resume()
    }
    
    // Method helpers for subclass
    
    func methodKeySubstitute(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    func methodParamsFromDictionary(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // Helpers for JSON parsing
    
    private func parseJSONData(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let newData: NSData
        if self.skipResponseDataLength != nil {
            newData = data.subdataWithRange(NSMakeRange(self.skipResponseDataLength!, data.length - self.skipResponseDataLength!)) /* subset response data! */
        } else {
            newData = data
        }
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
}