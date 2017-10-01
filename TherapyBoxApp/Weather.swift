//
//  Weather.swift
//  TherapyBoxApp
//
//  Created by Jake Holdom on 14/09/2017.
//  Copyright © 2017 Jake Holdom. All rights reserved.
//

import UIKit

class Weather: NSObject {
    
    var date = Date()
    var minTemp = ""
    var maxTemp = ""
    var weatherDescription = ""
    
    init(_date : Date, _minTemp : String, _maxTemp : String, _weatherDescription : String) {
        
        self.date = _date
        self.minTemp = _minTemp
        self.maxTemp = _maxTemp
        self.weatherDescription = _weatherDescription
        
        
    }
    
}
