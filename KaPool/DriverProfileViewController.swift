//
//  DriverProfileViewController.swift
//  KaPool
//
//  Created by  Alex Sumak on 4/30/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit

class DriverProfileViewController: UIViewController {

  // driver info
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ageLabel: UILabel!
  @IBOutlet weak var infoText: UITextView!
  @IBOutlet weak var smokingImage: UIImageView!
  @IBOutlet weak var foodImage: UIImageView!
  @IBOutlet weak var driverImage: UIImageView!
  
  //car info
  @IBOutlet weak var carImage: UIImageView!
  @IBOutlet weak var yearLabel: UILabel!
  @IBOutlet weak var makeLabel: UILabel!
  @IBOutlet weak var modelLabel: UILabel!
  @IBOutlet weak var colorLabel: UILabel!
  
  
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
