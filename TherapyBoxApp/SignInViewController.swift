//
//  SignInViewController.swift
//  TherapyBoxApp
//
//  Created by Jake Holdom on 19/09/2017.
//  Copyright © 2017 Jake Holdom. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet var loginTypeSwitch: UISwitch!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var usernameTextfield: UITextField!
    
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var signinButton: UIButton!
    
    var parentView : ViewController? = nil
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.errorLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Alternates between button title text depending on whether the user wants to sign in or create an account.
     */
    @IBAction func typeSwitchChanged(_ sender: Any) {
        if self.loginTypeSwitch.isOn {
            self.signinButton.titleLabel?.text = "Sign In"
    
        }else{
            self.signinButton.titleLabel?.text = "Create Account"
            
        }
        
        
        
    }
    
    /**
     Verifies the user's credentials and loads their previous account, or creates a new account with the provided username 
     and password
     */
    @IBAction func signInPressed(_ sender: Any) {
        
        if !(usernameTextfield.text?.isEmpty)! && !(passwordTextfield.text?.isEmpty)! {
            
            
            let accountsCoded = defaults.object(forKey: "userAccounts") as! Data //Loads an array of all of the user's that have been created
            var accounts = NSKeyedUnarchiver.unarchiveObject(with: accountsCoded) as! Array<Profile>

            
            if self.loginTypeSwitch.isOn { //Checks whether user is signing in or creating an account
                
                let userAccount = accounts.filter({$0.username == self.usernameTextfield.text}).first //Checks to see if the username exists
                
                if userAccount == nil { // Error message saying the user doesn't exist.
                    showError(type: 1)
                }else{
                    if passwordTextfield.text == (userAccount?.password)! { //Successful login as password is correct
                        logInAccount(userAccount: userAccount!)
                 
                        
                    }else{
                        
                        showError(type: 3) //Error password isn't correct
                    }
                    
                }
                
            }else{ //Creating accout
                
                if !(usernameTextfield.text?.isEmpty)! && !(passwordTextfield.text?.isEmpty)! {
                    
                    
                    let checkIfAccountExists = accounts.filter({$0.username == self.usernameTextfield.text})
                    if !checkIfAccountExists.isEmpty {
                        
                        showError(type: 4) //Error message stating the user already exists.
                        
                    }else{
                        let accountToAdd = OtherProfile(_username: usernameTextfield.text!, _password: passwordTextfield.text!)
                        
                        accounts.append(accountToAdd)
                        
                        let encodedAccountsArray = NSKeyedArchiver.archivedData(withRootObject: accounts)
                        defaults.set(encodedAccountsArray, forKey: "userAccounts") //Adds account to list of user accounts saved in the user defaults
                        
                        
                        logInAccount(userAccount: accountToAdd)
                        
                    }
                    
                    
                    
                }else{
                    
                    checkWhichFieldIsEmpty() // Error message due a field being empty
                }
                
                
                
            }
        }else{
            
            checkWhichFieldIsEmpty()
            
            
        }
        
        
        
    }
    
    
    /**
    Sets the Singleton LoggedInProfile object with the attributes provided by the user.
     - parameters:
     - userAccount: Profile object containing the user's attributes
     */
    private func logInAccount(userAccount : Profile){

        LoggedInProfile.sharedInstance.username = (userAccount.username)
        LoggedInProfile.sharedInstance.password = (userAccount.password)
        
        let encodedAccount = NSKeyedArchiver.archivedData(withRootObject: userAccount)

        defaults.set(encodedAccount, forKey: "loggedInProfile")
        self.parentView?.loginPressed(self)

       
    }
    
    private func checkWhichFieldIsEmpty(){
        if (usernameTextfield.text?.isEmpty)! {
            showError(type: 2)
        }else if (passwordTextfield.text?.isEmpty)! {
            showError(type: 3)
        }
        
    }
    
    private func showError(type : Int){
        
        self.errorLabel.isHidden = false
        switch type {
        case 0:
            errorLabel.text = "Error: Wrong Password"
        case 1:
            errorLabel.text = "Error: Account Not Found"
        case 2:
            errorLabel.text = "Error: No Username Entered"
        case 3:
            errorLabel.text = "Error: No Password Entered"
        case 4:
            errorLabel.text = "Error: Account Already Exists"
        default:
            errorLabel.text = "Error: Unknown"
        }
        
        
        
    }
    
}
