//
//  DataHandler.swift
//  On The Map
//
//  Created by Rishav on 19/04/17.
//  Copyright © 2017 Rishav. All rights reserved.
//

import Foundation
class DataHandler {
    static let shared = DataHandler()
    
    func handleErrors(_ data: Data?, _ response: URLResponse?, _ error: NSError?, completionHandler: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        guard (error == nil) else {
            completionHandler(nil, false, ConstantsUdacity.NetworkProblem)
            return
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            completionHandler(nil, false, ConstantsUdacity.IncorrectDetail)
            return
        }
        
        guard let _ = data else {
            completionHandler(nil, false, ConstantsUdacity.NoData)
            return
        }
    }
    
}
