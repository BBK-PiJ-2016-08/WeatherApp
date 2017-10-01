//
//  SearchLocations.swift
//  TherapyBoxApp
//
//  Created by Jake Holdom on 17/09/2017.
//  Copyright © 2017 Jake Holdom. All rights reserved.
//

import UIKit

class SearchLocations: NSObject {

    var longitude = ""
    var latitude = ""
    var countryName = ""
    var name = ""
    
    init(_longitude : String, _latitude : String, _countryName : String, _name : String) {
        
        self.longitude = _longitude
        self.latitude = _latitude
        self.countryName = _countryName
        self.name = _name
        
    }
    
    
}
