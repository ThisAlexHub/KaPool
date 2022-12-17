//
//  Map.swift
//  KaPool
//
//  Created by Madel Asistio on 5/26/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Parse
import Alamofire


class Map: NSObject {
    

    
    
    class func fetchMapData(mapView: GMSMapView, from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: @escaping (_ time: Int )->()) {
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?" +
            "origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&" +
        "key=AIzaSyBXq3sMUeCLnoAkjSvKWaMSXvMKrDLyZ0s"
        
        
        
        Alamofire.request(directionURL).responseJSON
            { response in
                
                if let JSON = response.result.value {
                    
                    let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                    
                    let routesArray = (mapResponse["routes"] as? Array) ?? []
                    
                    let routes = (routesArray.first as? Dictionary<String, Any>) ?? [:]
                    
                    let legs = routes["legs"] as! Array<Dictionary<String, Any>>
                    let totalSecs = travelMins(legs: legs)
                    
                    
                    let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
                    let polypoints = (overviewPolyline["points"] as? String) ?? ""
        
                    let line  = polypoints
                    
                    self.addPolyLine(mapView: mapView, encodedString: line)
              
                    completion(totalSecs)
                }
        }
        
  
        
    }
    
    
    class func travelMins(legs: Array<Dictionary<String, Any>>) -> Int {
        
        var totalDistanceInMeters = 0
        var totalDurationInSeconds = 0
        
        for leg in legs {
            print (leg)
            
            let dist = leg["distance"] as! Dictionary<String,Any>
            let dur = leg["duration"] as! Dictionary<String,Any>
           
        
            totalDistanceInMeters += dist["value"] as! Int
            totalDurationInSeconds += dur["value"] as! Int
        }
        
        
 //       let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
   //     let totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        
   //     var totalDuration = ""
     //   var totalStr = stringifyDur(mins: Double(remainingMins), hours: Double(remainingHours), days: Double(days))

        return totalDurationInSeconds
        
    }
    
    class func stringifyDur(totalDurInSec: Int) -> String {
        
        let mins = totalDurInSec / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        //      let remainingSecs = totalDurationInSeconds % 60

        
        var totalDuration = ""
        if days != 0 {
            totalDuration = "\(days) d, \(remainingHours) h, \(remainingMins) mins"
        } else if hours != 0 {
            totalDuration = "\(remainingHours) h, \(remainingMins) mins"
        } else if mins != 0 {
            totalDuration = "\(remainingHours) mins"
        }
        
        return totalDuration
    }
    
    class func addPolyLine(mapView: GMSMapView, encodedString: String) {
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5
        polyline.strokeColor = .blue
        polyline.map = mapView
        
    }


}
