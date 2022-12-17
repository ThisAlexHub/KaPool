//
//  NotifCell.swift
//  KaPool
//
//  Created by Madel Asistio on 5/22/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit

class NotifCell: UITableViewCell {
    var testID: String?

    @IBOutlet weak var fromLabel: UILabel!
    var ride: Ride!
    
    var riderName: String!
    var destName: String!
    var departDate: Date!
    
    var trip: Trip! {
        didSet {
            
            //get user
            User.getUser(userid: (trip?.riderID)!) { (rider: User) in
                self.riderName = rider.username!
                
                // get ride
                Ride.getRideWithId(rideId: self.trip.rideID!) { (ride: Ride) in
                    self.ride = ride
                    self.riderName = ride.destName!
                    self.departDate = ride.departDate!
                    
                    let dateStr = self.departDate.toString(dateFormat: "MM/dd h:mm a")
                    
                    
                    let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)]
                    let dateBold = NSMutableAttributedString(string:dateStr, attributes:attrs)
                    let nameBold = NSMutableAttributedString(string:rider.username! as String, attributes:attrs)
                    let destBold = NSMutableAttributedString(string:self.ride.destName! as String, attributes:attrs)

                    
                    let txtStr = NSMutableAttributedString(string:"")
                   
                    if self.trip.response == 0 {
                        
                        txtStr.append(nameBold)
                        txtStr.append(NSMutableAttributedString(string:" is a requesting a ride to "))
                        txtStr.append(destBold)
                        txtStr.append(NSMutableAttributedString(string:" on "))
                        txtStr.append(dateBold)
                      //  "\(nameBold) is a requesting a ride to \(destBold) on \(dateBold)"
                    } else if self.trip.response == -1 {
                        
                        txtStr.append(NSMutableAttributedString(string:"You declined "))
                        txtStr.append(nameBold)
                        txtStr.append(NSMutableAttributedString(string:" for a ride to "))
                        txtStr.append(destBold)
                         txtStr.append(NSMutableAttributedString(string:" on "))
                        txtStr.append(dateBold)
                       // txtStr = "You have declined \(nameBold) for a ride to \(destBold) on \(dateBold)"
                    } else if self.trip.response == 1 {
                       // txtStr = "You have accepted \(nameBold) for a ride to \(destBold) on \(dateBold)"
                        txtStr.append(NSMutableAttributedString(string:"You accepted "))
                        txtStr.append(nameBold)
                        txtStr.append(NSMutableAttributedString(string:" for a ride to "))
                        txtStr.append(destBold)
                        txtStr.append(NSMutableAttributedString(string:" on "))
                        txtStr.append(dateBold)
                    }
                    
                    self.fromLabel.attributedText = txtStr
                }
                
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        /*
        print(trip?.riderID!)
        User.getUser(userid: (trip?.riderID)!) { (rider: User) in
            self.fromLabel.text = rider.username
            
        } */
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
