//
//  ParseClient.swift
//  On The Map
//
//  Created by Rishav on 19/04/17.
//  Copyright © 2017 Rishav. All rights reserved.
//

import UIKit

class ParseClient: NSObject {

    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }

    func getStudentLocations(completionHandlerForGetLocations: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(ConstantsParse.ApiUrl)/\(ConstantsParse.LocationOfStudents)\(ConstantsParse.LimitAndOrder)")!)
        request.addValue(ConstantsParse.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ConstantsParse.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = UdacityClient.sharedSession
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                completionHandlerForGetLocations(nil, false, ConstantsUdacity.NetworkProblem)
                return
            }
            
            DataHandler.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForGetLocations)
            
            self.parseData(data!, completionHandlerForConvertedData: completionHandlerForGetLocations)
        }
        
        task.resume()
    }

    func postStudentLocation(mapString: String, mediaUrl: String, latitude: Double, longitude: Double, completionHandlerForPostLocation: @escaping (_ result: [String:AnyObject]?, _ success: Bool,  _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(ConstantsParse.ApiUrl)/\(ConstantsParse.LocationOfStudents)")!)
        request.httpMethod = "POST"
        request.addValue(ConstantsParse.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ConstantsParse.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonDict: [String:Any] = [
            "uniqueKey": UdacityClient.accountID!,
            "firstName": UdacityClient.firstName!,
            "lastName": UdacityClient.lastName!,
            "mapString": mapString,
            "mediaURL": mediaUrl,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let session = UdacityClient.sharedSession
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                completionHandlerForPostLocation(nil, false, ConstantsUdacity.NetworkProblem)
                return
            }
            
            DataHandler.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPostLocation)
            
            self.parseData(data!, completionHandlerForConvertedData: completionHandlerForPostLocation)
            
            
            
        }
        task.resume()
    }
    
    func displayStudentLocations(_ completionHandlerForAnnotations: @escaping (_ result: [LocationOfStudents]?, _ success: Bool, _ error: String?) -> Void) {
        
        ParseClient.sharedInstance().getStudentLocations { (results, success, error) in
            if success {
                if let data = results!["results"] as AnyObject? {
                    LocationOfStudents.Location.removeAll()
                    for result in data as! [AnyObject] {
                        let student = LocationOfStudents(dictionary: result as! [String : AnyObject])
                        LocationOfStudents.Location.append(student)
                    }
                    completionHandlerForAnnotations(LocationOfStudents.Location, true, nil)
                }
            } else {
                completionHandlerForAnnotations(nil, false, error)
            }
        }
    }
        private func parseData(_ data: Data, completionHandlerForConvertedData: (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        let parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
        } catch {
            completionHandlerForConvertedData(nil, false, "There was an error parsing the JSON")
            return
        }
        completionHandlerForConvertedData(parsedResult as? [String:AnyObject], true, nil)
    }
}
