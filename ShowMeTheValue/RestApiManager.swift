//
//  RestApiManager.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/19/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

import SwiftyJSON

typealias ServiceResponseJson = (JSON, NSError?) -> Void
typealias ServiceResponseXML = (Data?, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()  // Singleton for REST manager
    
    // MARK: Perform a GET Request for XML
    func makeHTTPGetRequestXML(path: String, onCompletion: @escaping ServiceResponseXML) {
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            onCompletion(data, error as NSError?)
        })
        task.resume()
    }
    
    // MARK: Perform a GET Request for JSON
    func makeHTTPGetRequestJSON(path: String, onCompletion: @escaping ServiceResponseJson) {
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json:JSON = JSON(data: jsonData)
                onCompletion(json, error as NSError?)
            } else {
                onCompletion(JSON.null, error as NSError?)
            }
        })
        task.resume()
    }
    
    /* Uncomment to enable POST Requests - Not used for this project
    // MARK: Perform a POST Request
    func makeHTTPPostRequest(path: String, body: [String: AnyObject], onCompletion: @escaping ServiceResponse) {
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        
        // Set the method to POST
        request.httpMethod = "POST"
        
        do {
            // Set the POST body for the request
            let jsonBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonBody
            let session = URLSession.shared
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                if let jsonData = data {
                    let json:JSON = JSON(data: jsonData)
                    onCompletion(json, nil)
                } else {
                    onCompletion(JSON.null, error as NSError?)
                }
            })
            task.resume()
        } catch {
            // Create your personal error
            onCompletion(JSON.null, nil)
        }
    }*/
}

