//
//  Ride.swift
//  KaPool
//
//  Created by Jake Vo on 4/17/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//
import Foundation

import UIKit
import Parse
import GooglePlaces

class Ride: NSObject {
    
    var driver: String = ""
    var originID: String?
    var destinationID: String?
    var departDate: Date?
    var price: Double?
    var seats: Int?
    var seatsRemaining: Int?
    var rideID: String?
    var destName: String?
    var originName: String?
    var radius:Double?
    var originLat:CLLocationDegrees?
    var originLon:CLLocationDegrees?
    
    var destLat:CLLocationDegrees?
    var destLon:CLLocationDegrees?
    
    
    
    init(_ ride: PFObject?) {
        
        super.init()
        
        
        self.driver = ride?.object(forKey: "Driver") as! String
        self.departDate = ride?.object(forKey: "Date") as? Date
        self.price = ride?.object(forKey: "Price") as! Double?
        self.seats = ride?.object(forKey: "SeatsAvail") as! Int?
        self.seatsRemaining = ride?.object(forKey: "seatsRemaining") as! Int?
        self.rideID = ride?.objectId
        self.originID = ride?.object(forKey: "Origin") as? String
        self.destinationID = ride?.object(forKey: "Destination") as? String
        self.destName = ride?.object(forKey: "destName") as? String
        self.originName = ride?.object(forKey: "originName") as? String

        self.radius = ride?.object(forKey: "PickupRadius") as? Double
        
        self.originLat = ride?.object(forKey: "originLat") as? Double
        self.originLon = ride?.object(forKey: "originLon") as? Double
        
        self.destLat = ride?.object(forKey: "destLat") as? Double
        self.destLon = ride?.object(forKey: "destLon") as? Double
  

    }
    
    class func addRide(destination: GMSPlace?, origin: GMSPlace?, radius: Double?, originLat: Double?, originLon: Double?, destLat:Double?, destLon:Double?, price: Double?, departDate: Date?, seats: Int?, withCompletion completion: PFBooleanResultBlock?) {
        
        
        let placesClient = GMSPlacesClient()
        // create Parse object PFObject
        let ride = PFObject(className: "Ride")
        
        // saves ride information into database
        ride["Price"] = price
        ride["Date"] = departDate
        ride["Destination"] = destination?.placeID
        ride["Origin"] = origin?.placeID
        ride["Active"] = true
        ride["SeatsAvail"] = seats
        ride["seatsRemaining"] = seats
        ride["Driver"] = PFUser.current()?.objectId
        ride["PickupRadius"] = radius
        
        ride["originLat"] = originLat
        ride["originLon"] = originLon
        
        ride["destLat"] = destLat
        ride["destLon"] = destLon
            
        placesClient.lookUpPlaceID((origin?.placeID)!, callback: { (place, error) -> Void in
            
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            print("the place is \(place!.name)")
           
            ride["originName"] = place!.name
            
        })
        
        placesClient.lookUpPlaceID((destination?.placeID)!, callback: { (place, error) -> Void in
            
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            
            ride["destName"] = place!.name
            
             ride.saveInBackground(block: completion)
        })
        
    }
    
    class func getRideWithId(rideId: String, completion:@escaping (_ ride: Ride) -> ()) {
        
        let qry = PFQuery(className: "Ride")
        //qry.whereKey("objectID", equalTo: userid)
        // qry.limit = 1
        qry.getObjectInBackground(withId: rideId) { (ride: PFObject?, error: Error?) -> Void in
            if error == nil && ride != nil {
                
                completion(Ride.init(ride!))
                
            } else {
                
                print("Error: \(String(describing: error))")
            }
        }
    }
    
}


