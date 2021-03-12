//
//  LoginViewController.swift
//  igClone
//
//  Created by Jackson Lu on 3/11/21.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signIn(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        //one of param was PRUser? meaning optional that can be nil. when the callback is called with a user and error param, it means user can be nil. so we check for htat
        PFUser.logInWithUsername(inBackground: username, password: password) { ( user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSignup", sender: nil)
            }
            else{
                print("Error \(error?.localizedDescription )")
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text!
        user.password = passwordField.text!
        
        user.signUpInBackground { (success, error) in
            if success{
                self.performSegue(withIdentifier: "loginSignup", sender: nil)
            }
            else{
                print("Error \(error?.localizedDescription )")
            }
        }
    }
    
}
