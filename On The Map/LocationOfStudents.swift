//
//  LocationOfStudents.swift
//  On The Map
//
//  Created by Rishav on 19/04/17.
//  Copyright © 2017 Rishav. All rights reserved.
//

import Foundation
struct LocationOfStudents {
    
    static var Location = [LocationOfStudents]()
    
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapStr: String?
    var mediaURL: String?
    var uniqueKey: String?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    init(dictionary: [String:AnyObject]) {
        self.firstName = dictionary["firstName"] as? String
        self.lastName = dictionary["lastName"]  as? String
        self.latitude = dictionary["latitude"]  as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.mapStr = dictionary["mapString"] as? String
        self.mediaURL = dictionary["mediaURL"]  as? String
        self.uniqueKey = dictionary["uniqueKey"] as? String
    }
    
}
