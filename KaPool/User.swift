//
//  User.swift
//  KaPool
//
//  Created by Madel Asistio on 5/12/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.


import UIKit
import Parse

class User: NSObject {
    
    var carColor: String?
    var carMake: String?
    var carModel: String?
    var userID: String?
    var emailVerified: Bool?
    var username: String?
    var phoneNum: Int?
    var email: String?
    var profilePic:UIImage?
  
    init(_ user:PFObject){
      super.init()
      //self.driver = ride?.object(forKey: "Driver") as! String
      
      self.username = user.object(forKey: "username") as? String
        
      let usernameArr = self.username?.components(separatedBy: "@")
        
      if (usernameArr?.count)! > 0 {
            self.username = usernameArr?[0]
      }
      self.carColor = user.object(forKey: "carColour") as? String
      self.carModel = user.object(forKey: "carModel") as? String
      self.carMake = user.object(forKey: "carMake") as? String
      self.userID = user.objectId
      self.emailVerified = user.object(forKey: "emailVerified") as? Bool
      self.email = user.object(forKey: "email") as? String
      self.profilePic = user.object(forKey: "profilePic") as? UIImage
      
    
    }
    
    class func getUser(userid: String, completion: @escaping (_ user: User) -> ()) {
        
        let qry = PFQuery(className: "_User")
        //qry.whereKey("objectID", equalTo: userid)
        // qry.limit = 1
        qry.getObjectInBackground(withId: userid) { (user: PFObject?, error: Error?) -> Void in
            if error == nil && user != nil {
                
                completion(User.init(user!) )
                
            } else {
                
                print("Error: \(String(describing: error))")
            }
        }
    }

  
}
