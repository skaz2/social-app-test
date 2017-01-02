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
import SwiftKeychainWrapper

class SignInVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("INFO: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        pwdField.resignFirstResponder()
        return true
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
                if let user = user {
                let userData = ["provider": user.providerID]
                self.completeSignIm(id: user.uid, userData: userData)
                }
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
                            if let user = user {
                            let userData = ["provider": user.providerID]
                            self.completeSignIm(id: user.uid, userData: userData)
                            }
                        } else {
                            print("INFO: Successfully authenticated with Firebase")
                            if let user = user {
                            let userData = ["provider": user.providerID]
                                self.completeSignIm(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    
    func completeSignIm(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("INFO: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }

}

