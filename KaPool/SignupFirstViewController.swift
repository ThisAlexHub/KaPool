//
//  SignupFirstViewController.swift
//  KaPool
//
//  Created by Jake Vo on 4/10/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import Parse
import mailgun

class SignupFirstViewController: UIViewController {
    
    
    

    @IBOutlet var nameText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var confirmPassText: UITextField!
    @IBOutlet var phoneNumText: UITextField!
    let appName = "Kapool"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.verifyEmail()

        // Do any additional setup after loading the view.
    }

    @IBAction func onSignup(_ sender: Any) {
        
        if (nameText.text?.isEmpty)! || (emailText.text?.isEmpty)! || (passwordText.text?.isEmpty)! || (confirmPassText.text?.isEmpty)! || (phoneNumText.text?.isEmpty)! {
            
            
            alertControl(title: appName, message: "Please fill all fields!")
            
        } else {
            
            
            if passwordText.text != confirmPassText.text {
                
                alertControl(title: appName, message: "Passwords do not match")
                
            } else {
                
                let newUser = PFUser()
                
                
                newUser.email = emailText.text
                newUser.password = passwordText.text
                newUser.username = emailText.text
                newUser["phoneNum"] = Int(phoneNumText.text!)
                
                newUser.signUpInBackground(block: { (success, error) in
                    
                    //self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if error != nil {
                        
                        var displayErrorMessage = "Please try again later."
                        
                        let error = error as NSError?
                        
                        if let errorMessage = error?.localizedDescription {
                            displayErrorMessage = errorMessage
                        }
                        
                        self.alertControl(title: self.appName, message: displayErrorMessage)
                        
                    } else {
                        
                        
                        self.alertControl(title: self.appName, message: "Signed up Successfully")
                        
                        
                        UserDefaults.standard.set(newUser.username, forKey: "username")
                        UserDefaults.standard.synchronize()
                        
                        //self.performSegue(withIdentifier: "showHomepage", sender: self)
                        //let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        //appDelegate.login()
                    }
                })
            }
        }
    }
    
    func verifyEmail () {
       /* let session = URLSession.shared
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.mailgun.net/v3/https://api.mailgun.net/v3/sandboxae2893df622b4453980b0dcaebe136dc.mailgun.org/messages")! as URL)
        
        request.httpMethod = "POST"
        let credentials = "api:key-26ed8d792fb56983f3d0f65c8ed18487"
        
        request.setValue("Basic \(credentials.toBase64())", forHTTPHeaderField: "Authorization")
        
        let data = "from: Swift Email <postmaster@sandboxae2893df622b4453980b0dcaebe136dc.mailgun.org>&to: <madel.asistio@gmail.com>&subject:Hello&text:Testing_some_Mailgun_awesomness"
        request.httpBody = data.data(using: String.Encoding.ascii)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let error = error {
                print(error)
            }
            if let response = response {
                print("url = \(response.url!)")
                print("response = \(response)")
                let httpResponse = response as! HTTPURLResponse
                print("response code = \(httpResponse.statusCode)")
            }
        })
        task.resume() */
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: "https://api.mailgun.net/v3/sandboxae2893df622b4453980b0dcaebe136dc.mailgun.org/messages")! as URL)
        request.httpMethod = "POST"
        
        let username = "api"
        let password = "key-26ed8d792fb56983f3d0f65c8ed18487"
        
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
        
        let base64LoginString = loginData.base64EncodedString(options: [])
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let bodyStr = "from=Mailgun Sandbox <mailgun@sandboxae2893df622b4453980b0dcaebe136dc.mailgun.org>&to=Receiver name <madel.asistio@gmail.com>&subject=Test&text=thank you!"

        // appending the data
        request.httpBody = bodyStr.data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            // ... do other stuff here
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("email sent")
            }
            
        })
        
        task.resume()
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

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
