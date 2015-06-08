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
    var skipResponseDataLength: Int? = nil
    
    func httpGet(url: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
                return
            }
            
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
        task.resume()
    }
    
    func httpPost(url: String, httpBodyParams: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(httpBodyParams, options: nil, error: nil)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
                return
            }
            
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
        task.resume()
    }
    
    func httpDelete() {
        
    }
    
    private func parseJSONData() {
        
    }
}