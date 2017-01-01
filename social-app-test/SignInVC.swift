//
//  SignInVC.swift
//  social-app-test
//
//  Created by Admin on 27.09.16.
//  Copyright © 2016 Sergey Kharlamov. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SignInVC: UIViewController {
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
         
            if error != nil {
                print("INFO: Unable to authenticate witn Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("INFO: User cancelled Facebook authentication")
            } else {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            
            if error != nil {
                print("INFO: Unable to authenticate with FIrebase - \(error)")
                
            } else {
                print("INFO: Succesfully authenticated with Firebase")
            }
        })
    }

    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("INFO: Email user authenticated with Firebase")
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("INFO: Unable to authenticate with Firebase using email")
                        } else {
                            print("INFO: Successfully authenticated with Firebase")
                        }
                    })
                }
            })
        }
    }

}

