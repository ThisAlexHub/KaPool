//
//  Trip.swift
//  KaPool
//
//  Created by Madel Asistio on 5/21/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import Parse

class Trip: NSObject {
    
    var tripID: String?
    var createdAt: Date?
    var updatedAt: Date?
    var rideID: String?
    var riderID: String?
    var driverID: String?
    var pickupName: String?
    var pickupLocation: CLLocation?
    var response: Int?
    
    
    
    init(_ trip: PFObject) {
        
        super.init()
        
        self.tripID = trip.objectId
        self.createdAt = trip.createdAt
        self.updatedAt = trip.updatedAt
        self.rideID = trip.object(forKey: "rideID") as? String
        self.riderID = trip.object(forKey: "riderID") as? String
        self.driverID = trip.object(forKey: "driverID") as? String
        self.pickupName = trip.object(forKey: "pickupLoc") as? String
        self.response = trip.object(forKey: "driverResponse") as? Int
        
        let lat = trip.object(forKey: "pickupLat") as! Double
        let lon = trip.object(forKey: "pickupLong") as! Double
        
        let userLocation:CLLocation = CLLocation(latitude: lat, longitude: lon)
        
        self.pickupLocation = userLocation
    }
    
    class func addTrip(rideid: String, pickupName: String, pickupLocation: CLLocation, driverAccepted: Bool, riderid: String, driverid: String, withCompletion completion: PFBooleanResultBlock?) {
        
        let trip = PFObject(className: "Trip")
        
        trip["rideID"] = rideid
        trip["pickupLoc"] = pickupName
        trip["pickupLong"] = pickupLocation.coordinate.longitude
        trip["pickupLat"] = pickupLocation.coordinate.latitude
        trip["driverResponse"] = 0
        trip["riderID"] = riderid
        trip["driverID"] = driverid
        
        
        trip.saveInBackground(block: completion)
        
        
    }
    
    class func getNotifs(withCompletion completion: @escaping (_ trips: [Trip] ) -> ()) {
        
        var notifications: [Trip] = []
        let user = User.init(PFUser.current()!)
        
        let query = PFQuery(className: "Trip")
        
        // fetch data asynchronously
        query.findObjectsInBackground { (notifs: [PFObject]?, error: Error?) -> Void in
           
            if let notifs = notifs {
                // do something with the array of object returned by the call
                
                if notifs.count > 0 {
                    
                    for notif in notifs {
    
                        if (user.userID == notif.object(forKey: "driverID") as? String) {
                            notifications.append(Trip.init(notif))
                        }
                    }
            
                    completion(notifications)
                    
                } else {
                    print ("No Notifications Found")
                }
            }
        }
        
    }
    
    // get all trips that have been accepted
    class func getTrips(rideid: String, completion: @escaping (_ trips: [Trip]) -> ()) {
        getNotifs() { (trips: [Trip]) in
            
            var tripsFound: [Trip] = []
            
            // gets all valid trips for the current ride
            for trip in trips {
                if trip.rideID == rideid && trip.response == 1 {
                    tripsFound.append(trip)
                }
            }
            
            completion(tripsFound)
        }
    }
}
