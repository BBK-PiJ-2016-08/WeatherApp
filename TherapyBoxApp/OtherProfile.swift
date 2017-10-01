//
//  OtherProfile.swift
//  TherapyBoxApp
//
//  Created by Jake Holdom on 19/09/2017.
//  Copyright © 2017 Jake Holdom. All rights reserved.
//

import UIKit

class OtherProfile: NSObject, NSCoding, Profile {
    var username : String = String()
    var password : String = String()
    
    
    init(_username : String, _password : String) {
        self.username = _username
        self.password = _password
    }
    
    
    required init?(coder aDecoder: NSCoder) { //Decoder in order to be able to save the object in the user defaults
        self.username = (aDecoder.decodeObject(forKey: "username") as! NSString) as String
        self.password = (aDecoder.decodeObject(forKey: "password") as! NSString) as String
    }
    
    
    public func encode(with aCoder: NSCoder){
        aCoder.encode(username, forKey: "username")
        aCoder.encode(password, forKey: "password")
        
    }
    


}
