//
//  SignOutViewController.swift
//  TherapyBoxApp
//
//  Created by Jake Holdom on 19/09/2017.
//  Copyright © 2017 Jake Holdom. All rights reserved.
//

import UIKit

class SignOutViewController: UIViewController {

    @IBOutlet var signedInAsLabel: UILabel!
    var parentView : ViewController? = nil

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signedInAsLabel.text = "Signed in as: \(LoggedInProfile.sharedInstance.username)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Clears LoggedInProfile singleton and removes the profile from the user defaults.
     */
    @IBAction func logoutPressed(_ sender: Any) {
        
        self.parentView?.loginPressed(self)

        LoggedInProfile.sharedInstance.loggedIn = false
        LoggedInProfile.sharedInstance.username = ""
        LoggedInProfile.sharedInstance.password = ""
        let defaults = UserDefaults.standard

        defaults.set(nil, forKey: "loggedInProfile")
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
