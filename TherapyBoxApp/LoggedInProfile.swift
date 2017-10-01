//
//  LogginInProfile.swift
//  TherapyBoxApp
//
//  Created by Jake Holdom on 19/09/2017.
//  Copyright © 2017 Jake Holdom. All rights reserved.
//

import UIKit

class LoggedInProfile: NSObject, Profile {

    var username : String = ""
    var password : String = ""
    var loggedIn : Bool = false
    
    static let sharedInstance = LoggedInProfile()
    


    
}
