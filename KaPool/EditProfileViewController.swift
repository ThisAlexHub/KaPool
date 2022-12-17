//
//  EditProfileViewController.swift
//  KaPool
//
//  Created by  Alex Sumak on 5/21/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  //user
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var ageField: UITextField!

  
  //car
  @IBOutlet weak var carYearField: UITextField!
  @IBOutlet weak var carMakeField: UITextField!
  @IBOutlet weak var carModelField: UITextField!
  @IBOutlet weak var carColorField: UITextField!
  
  // buttons
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var saveButton: UIButton!
  
  // user
  var fullname:String?
  var age:String?
  
    // car
  var carYear:String?
  var carMake:String?
  var carModel:String?
  var carColor:String?
  
  // image
  
  var im:UIImageView!
  
  
  @IBOutlet weak var profileImage: UIImageView!

 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameField?.text = fullname
        self.ageField?.text = age
        self.carYearField?.text = carYear
        self.carMakeField?.text = carMake
        self.carModelField?.text = carModel
        self.carColorField?.text = carColor
    
      
      
      
      
        //profileImage?.image = im.image
      
        
      
        //im.image = profileImage?.image
        profileImage?.layer.cornerRadius = (profileImage?.frame.size.width)! / 2
        profileImage?.clipsToBounds = true
      
        // Do any additional setup after loading the view.
      
 
      
      
      
      //button
      cancelButton.layer.cornerRadius = 10
      saveButton.layer.cornerRadius = 10
      
      //image
      self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
      self.profileImage.clipsToBounds = true;
      self.profileImage.layer.borderWidth = 3.0
      profileImage.layer.borderColor = UIColor.white.cgColor
      
      
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func onCancel(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onSave(_ sender: Any) {
    
    if(nameField?.text?.isEmpty)!{
      alertControl(title: "KaShare", message: "Please fill all fields!")
      
      
     
      
      
    } else {
      
      
      let user = PFUser.current()
      
      user?.username = self.nameField?.text
      
      UserDefaults.standard.set(user?.username, forKey: "username")
      UserDefaults.standard.synchronize()
      
      user?["fullname"] = self.nameField?.text
      
      
      let image = UIImagePNGRepresentation((profileImage?.image)!)
      let imageF = PFFile(name:"file.jpg", data:image!)
      
      user?["ProfilePic"] = imageF
      
      
      
      
      user?.saveInBackground(block: { (success, error) in
        if success {
          self.dismiss(animated: true, completion: nil)
          
          
          user?.saveInBackground(block: { (success, error) in
            if success {
              self.dismiss(animated: true, completion: nil)
          let postQuery = PFQuery(className: "User")
        
          postQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
              
            
              for object in objects! {
                print("Object is \(object["username"]!)")
            
                if object["username"]! as? String == self.fullname! {
                  object["username"] = self.nameField?.text
                  object["age"] = self.ageField?.text
                  
                  object["CarYear"] = self.carYearField?.text
                  object["carColour"] = self.carColorField?.text
                  object["carModel"] = self.carModelField?.text
                  object["carMake"] = self.carMakeField?.text
                  
                  
                  object["ProfilePic"] = imageF
                  object.saveInBackground()
                }
              }
              
            }
            
          })
          
        }
      })
        }
      })
      
      let userQuery = PFQuery(className: "_User")
      userQuery.findObjectsInBackground (block: { (objects, error) -> Void in
        if error == nil {
   
          for object in objects! {
            print("Object is \(object["username"]!)")
            if object["username"]! as? String == self.fullname! {
              object["age"] = self.ageField?.text
              
              object["CarYear"] = self.carYearField?.text
              object["carColour"] = self.carColorField?.text
              object["carModel"] = self.carModelField?.text
              object["carMake"] = self.carMakeField?.text
              object.saveInBackground()
            }
          }
          
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
  
  @IBAction func changeImage(_ sender: Any) {
    let picker  = UIImagePickerController()
    
    picker.delegate = self
    
    
    
    picker.sourceType = .photoLibrary
    
    picker.allowsEditing = true
    
    present(picker, animated:true, completion:nil)
    
    
    
  }
  
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    im?.image = info[UIImagePickerControllerEditedImage] as? UIImage
    self.dismiss(animated: true, completion: nil)
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
