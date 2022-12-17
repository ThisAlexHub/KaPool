//
//  SigninViewController.swift
//  KaPool
//
//  Created by Jake Vo on 4/14/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import Parse

class SigninViewController: UIViewController {

    
    @IBOutlet var emailText: UITextField!
    @IBOutlet var passwordText: UITextField!
    var signal = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: Any) {
        
        
        
        if (emailText.text?.isEmpty)! || (passwordText.text?.isEmpty)! {
            
            alertControl(title: "Error:", message: " Missing Username/Password!")
            
        } else {
            
            PFUser.logInWithUsername(inBackground: emailText.text!, password: passwordText.text!, block: { (user, error) in
                
                if error != nil {
                    
                    var displayErrorMessage = "Please try again later."
                    
                    //let error = error as NSError?
                    
                    if let errorMessage = error?.localizedDescription {
                        displayErrorMessage = errorMessage
                    }
                    
                    self.alertControl(title: "Login Error", message: displayErrorMessage)
                } else {
                    
                    print("Logged in")
                    
                    
                    UserDefaults.standard.set(user!.username, forKey: "username")
                    UserDefaults.standard.synchronize()
                    
                    if self.signal == "offer" {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "offerRide") as! OfferRideVC
                        
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()
                    //self.performSegue(withIdentifier: "showHomepage", sender: self)
                }
            })
        }
    }
    
    
    func alertControl (title: String, message: String) {
        
        let alertControler = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        //button in alert box
        alertControler.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alertControler, animated: true, completion: nil)
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
