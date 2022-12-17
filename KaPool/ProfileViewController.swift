//
//  ProfileViewController.swift
//  KaPool
//
//  Created by  Alex Sumak on 5/15/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {
  
  //self.profileImageView.layer.cornerRadius = 10.0f;
  
  @IBOutlet weak var editButton: UIButton!
  
  //@IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ageLabel: UILabel!
  @IBOutlet weak var infoLabel: UITextView!

  
  //car
  @IBOutlet weak var carMake: UILabel!
  @IBOutlet weak var carModel: UILabel!
  @IBOutlet weak var carColor: UILabel!
  @IBOutlet weak var carYear: UILabel!
  
  
  
  let defaults = UserDefaults.standard
  let user = PFUser.current()!
    override func viewDidLoad() {
        super.viewDidLoad()
  
      
      //button
      editButton.layer.cornerRadius = 10
      
      //image
      self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
      self.profileImage.clipsToBounds = true;
      self.profileImage.layer.borderWidth = 3.0
      profileImage.layer.borderColor = UIColor.white.cgColor
      
      
 
    }
  
  override func viewDidAppear(_ animated: Bool) {
    
    let username =  defaults.string(forKey: "username")
    
    
    self.navigationController?.navigationBar.topItem?.title = username
    let infoQuery = PFQuery(className: "_User")
    
     infoQuery.whereKey("username", equalTo: username!)
    
    infoQuery.findObjectsInBackground (block: { (objects, error) -> Void in
      if error != nil {
        
      
      } else {
        
        for object in objects! {
          
          //user
          self.nameLabel.text = (object.object(forKey: "username") as? String)
          self.ageLabel.text = (object.object(forKey: "age") as? String)
          self.infoLabel.text = (object.object(forKey: "about") as? String)
          
          let avaFile: PFFile = (object.object(forKey: "ProfilePic") as? PFFile)!
          
          avaFile.getDataInBackground { (data, error) in
            
            if let imageData = data {
              
              if let downloadedImage = UIImage(data: imageData) {
                
                print ("Inside here")
                self.profileImage.image = downloadedImage
                self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
                self.profileImage.clipsToBounds = true
              }
            }
          }
          
          
          //car
          self.carMake.text = (object.object(forKey: "carMake") as? String)
          self.carModel.text = (object.object(forKey: "carModel") as? String)
          self.carColor.text = (object.object(forKey: "carColour") as? String)
          self.carYear.text = (object.object(forKey: "CarYear") as? String)
          
        }
      }
    })
  }

  @IBAction func editProfileButton(_ sender: Any) {
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "editProfile") as! EditProfileViewController
    
    vc.fullname = nameLabel.text
    vc.age = ageLabel.text
    
    vc.carYear = carYear.text
    vc.carMake = carMake.text
    vc.carColor = carColor.text
    vc.carModel = carModel.text
    
    //vc.im = profileImage
    if profileImage != nil {
      
      vc.im = profileImage
    }
    
    
    //vc.im.image = profileImage.image
    
    self.present(vc, animated: true, completion: nil)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
