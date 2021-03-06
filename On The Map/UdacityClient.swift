//
//  UdacityClient.swift
//  On The Map
//
//  Created by Rishav on 19/04/17.
//  Copyright © 2017 Rishav. All rights reserved.
//

import UIKit

class UdacityClient: NSObject {
    static var sharedSession = URLSession.shared
    
  
    static var sessionID: String? = nil
    static var accountID: String? = nil
    static var firstName: String? = nil
    static var lastName: String? = nil
    
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    
    func authenticateUser(username: String, password: String, completionHandlerForAuth: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let _ = createSession( ConstantsUdacity.ApiSessionUrl, username: username, password: password) { (result, success, error) in
            
            guard let _ = result else {
                completionHandlerForAuth(false, ConstantsUdacity.NetworkProblem)
                return
            }
            
            guard let session = result?["session"], let sessionID = session["id"] as? String, let account = result?["account"], let accountID = account["key"] as? String else {
                print("Error")
                completionHandlerForAuth(false, ConstantsUdacity.IncorrectDetail)
                return
            }
            UdacityClient.sessionID = sessionID
            UdacityClient.accountID = accountID
            let _ = self.getPublicUserData(completionHandlerForPublicData: { (result, success, error) in
                guard let user = result?["user"] else {
                    print("Error")
                    return
                }
                
                guard let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String else {
                    print("Error")
                    return
                }
                
                // Store the user's name for later use
                UdacityClient.firstName = firstName as String?
                UdacityClient.lastName = lastName as String?
            })
            
            completionHandlerForAuth(true, nil)
        }
    }
    
   
    func getPublicUserData(completionHandlerForPublicData: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(ConstantsUdacity.ApiUserIdUrl)\(UdacityClient.accountID!)")!)
        
        let task = UdacityClient.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                completionHandlerForPublicData(nil, false, ConstantsUdacity.NetworkProblem)
                return
            }
            
            DataHandler.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPublicData)
            
          
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            
     
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForPublicData)
        }
        task.resume()
    }
    

    func createSession(_ url_path: String, username: String, password: String, completionHandlerForPOST: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: url_path)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonDict: [String: Any] = [
            "udacity": [
                "username": username,
                "password": password
            ]
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = UdacityClient.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                DataHandler.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPOST)
                return
            }
            
        
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            
        
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForPOST)
            
        }
        task.resume()
        
        return task
    }
    
 
    func endUserSession(completionHandlerForDeleteSession: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let _ = deleteSession { (result, success, error) in
            if success {
                completionHandlerForDeleteSession(true, nil)
            } else {
                completionHandlerForDeleteSession(false, error)
            }
        }
    }
    
    func deleteSession(completionHandlerForDELETE: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) -> URLSessionDataTask {
        
        
        let request = NSMutableURLRequest(url: URL(string:  ConstantsUdacity.ApiSessionUrl)!)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = UdacityClient.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                DataHandler.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForDELETE)
                return
            }
            
            DataHandler.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForDELETE)
            
       
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            
         
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForDELETE)
        }
        task.resume()
        
        return task
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertedData: (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
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
