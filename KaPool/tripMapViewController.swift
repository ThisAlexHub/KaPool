//
//  tripMapViewController.swift
//  KaPool
//
//  Created by Madel Asistio on 5/22/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import Parse

protocol tripMapViewControllerDelegate: class {
    func returningtoView(tripId: String, response: Int)
}

class tripMapViewController: UIViewController, GMSMapViewDelegate {
    
    weak var delegate: tripMapViewControllerDelegate?
    @IBOutlet weak var requestorPic: GMSMapView!
    
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var timeView: UIView!
   
    @IBOutlet weak var decisionView: UIView!
    var pickupLoc: CLLocation!
    var pickupName: String!
    var tripArr: [Trip] = []
    var otherRidersLoc: [Trip] = []
    var origin: GMSPlace?
    var destination: GMSPlace?
    var ride: Ride!
    let apiKey: String = "AIzaSyBXq3sMUeCLnoAkjSvKWaMSXvMKrDLyZ0s"
    var currTripID: String?
    
    @IBOutlet weak var extraTime: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Trip.getTrips(rideid: ride.rideID!) { (trips: [Trip]) in
            print ("TRIPS GOT")
            self.tripArr = trips
            
            let placesClient = GMSPlacesClient()
            
            placesClient.lookUpPlaceID((self.ride.originID)!, callback: { (place, error) -> Void in
                
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                
                self.origin = place
                
                placesClient.lookUpPlaceID((self.ride.destinationID)!, callback: { (place, error) -> Void in
                    
                    if let error = error {
                        print("lookup place id query error: \(error.localizedDescription)")
                        return
                    }
                    
                    self.destination = place
                    self.fixMap(trips: self.tripArr, handleComplete: {
                        self.handleViews()
                    })
                    /*
                    self.getOtherRiders(trips: self.tripArr, complete: {
                        
                        print("other riders got")
                        self.fixMap(trips: self.otherRidersLoc, handleComplete: {
                            print ("map done")
                            
                            // brings views to front
                            
                            self.handleViews()
                        })
                    }) */
                })
                
            })

        
        

        // Do any additional setup after loading the view.
        }
    }
    
    func handleViews() {

        
        self.decisionView.layer.shadowColor = UIColor.black.cgColor
        self.decisionView.layer.shadowOpacity = 0.5
        self.decisionView.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.mapView.bringSubview(toFront: self.decisionView)
        
        
        self.statsView.layer.shadowColor = UIColor.black.cgColor
        self.statsView.layer.shadowOpacity = 0.5
        self.statsView.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.mapView.bringSubview(toFront: self.statsView)
        
        
    }
    /*
    func getOtherRiders(trips: [Trip], complete:@escaping () -> ()) {
        
        //let placesClient = GMSPlacesClient()
       // let myGroup = DispatchGroup()
        
        for trip in trips {
            
            self.otherRidersLoc.append(trip)
        }
        
       /*
        var tripCt = 0
        while tripCt < trips.count {
            
           
            
            myGroup.enter()
            placesClient.lookUpPlaceID((trips[tripCt].pickupID)!, callback: { (place, error) -> Void in
                
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                
                self.otherRidersLoc.append(place!)
                myGroup.leave()
                
            })
            tripCt = tripCt + 1
        }
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            print("Finished all requests.")
            complete ()
        }) */
    } */
    
    func fixMap(trips: [Trip], handleComplete:@escaping (()->())) {
        
        let camera = GMSCameraPosition.camera(withLatitude: origin!.coordinate.latitude,
                                              longitude: origin!.coordinate.longitude,
                                              zoom: 5)
        mapView.camera = camera
        mapView.delegate = self
        
        var point1: CLLocationCoordinate2D?
        var point2: CLLocationCoordinate2D?
        
        let path = GMSMutablePath()
        
        var bounds = GMSCoordinateBounds()
        
        let ogMarker = GMSMarker()
        ogMarker.position = CLLocationCoordinate2D(latitude: origin!.coordinate.latitude, longitude: (origin?.coordinate.longitude)!)
        ogMarker.map = self.mapView
        ogMarker.title = "Origin"
        ogMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        
        let destMarker = GMSMarker()
        destMarker.position = CLLocationCoordinate2D(latitude: destination!.coordinate.latitude, longitude: destination!.coordinate.longitude)
        destMarker.map = self.mapView
        destMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        destMarker.title = "Destination"
        
        let currMarker = GMSMarker()
        currMarker.position = CLLocationCoordinate2D(latitude: pickupLoc!.coordinate.latitude , longitude: pickupLoc!.coordinate.longitude)
        currMarker.map = self.mapView
        currMarker.icon = GMSMarker.markerImage(with: UIColor.purple)
        currMarker.snippet = "YOU"
        
        path.add((origin?.coordinate)!)
        path.add((destination?.coordinate)!)
        
        
        bounds = bounds.includingCoordinate(ogMarker.position)
        
        if trips.isEmpty == true {
            bounds = bounds.includingCoordinate(destMarker.position)
        }
        
        point1 = origin?.coordinate
        point2 = pickupLoc?.coordinate
        
        var tripWithoutRider = 0
        var tripWithRider = 0
        
        for trip in trips {
            
            travelTime(from: point1!, to: point2!) { (totalSecs: Int) in
                let marker = GMSMarker()
                marker.position = (trip.pickupLocation?.coordinate)!
                marker.map = self.mapView
                marker.title = trip.pickupName
                
                path.add((trip.pickupLocation?.coordinate)!)
                
                bounds = bounds.includingCoordinate(marker.position)
                
                marker.icon = GMSMarker.markerImage(with: UIColor.blue)
                
                point2 = trip.pickupLocation?.coordinate
                
                self.fetchMapData(from: point1!, to: point2!)
                
                tripWithoutRider += totalSecs
                point1 = point2
                
            }
        }
        
        if trips.isEmpty == true {
            point2 = origin?.coordinate
        }
        
        // get trip with rider, point2 is last loc
        travelTime(from: point2!, to: (pickupLoc?.coordinate)!) { (totalSecs: Int) in
            tripWithRider = tripWithoutRider + totalSecs
            point2 = (self.pickupLoc?.coordinate)! // changed point2 to be riderLoc
        }
       
        travelTime(from: point1!, to: (destination?.coordinate)!) { (totalSecs: Int) in
            
            tripWithoutRider += totalSecs
            
            self.travelTime(from: point2!, to: (self.destination?.coordinate)!, returnTime: { (total: Int) in
                tripWithRider += total
                
                tripWithRider = tripWithoutRider + totalSecs
                
                let timeDiff = tripWithRider - tripWithoutRider
                let timeDiffTxt = Map.stringifyDur(totalDurInSec: timeDiff)
                
                self.extraTime.text = "+\(timeDiffTxt)"
                
                // adds origin and destination markers
                
                let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
                self.mapView.animate(with: update)
                
                //   getPolylineRoute(from: (origin?.coordinate)!, to: (destination?.coordinate)!)
                
                // drawPath(currentLocation: (origin?.coordinate)!, destinationLoc: (destination?.coordinate)!)
                self.fetchMapData(from: (self.origin?.coordinate)!, to: (self.destination?.coordinate)!)
                
                
                handleComplete()

            })
        }
    }
    
    func fetchMapData(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?" +
            "origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&" +
        "key=\(self.apiKey)"
        
        
        
        Alamofire.request(directionURL).responseJSON
            { response in
                
                if let JSON = response.result.value {
                    
                    let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                    
                    let routesArray = (mapResponse["routes"] as? Array) ?? []
                    
                    let routes = (routesArray.first as? Dictionary<String, Any>) ?? [:]
                    
                    
                    let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
                    let polypoints = (overviewPolyline["points"] as? String) ?? ""
                    let line  = polypoints
                    
                    self.addPolyLine(encodedString: line)
                }
        }
        
    }
    
    func travelTime (from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, returnTime: @escaping (
        _ totalSecs: Int) -> ()) {
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?" +
            "origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&" +
        "key=\(self.apiKey)"
    
        
        Alamofire.request(directionURL).responseJSON
            { response in
                
                if let JSON = response.result.value {
                    
                    let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                    
                    let routesArray = (mapResponse["routes"] as? Array) ?? []
                    
                    let routes = (routesArray.first as? Dictionary<String, Any>) ?? [:]
                    
                    let legs = routes["legs"] as! Array<Dictionary<String, Any>>
                    let totalSecs = Map.travelMins(legs: legs)
                 
                    
                    returnTime(totalSecs)
                }
        }
    }
  
    
    func addPolyLine(encodedString: String) {
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5
        polyline.strokeColor = .blue
        polyline.map = mapView
        
    }
    
    func travelMins(minString: String) {
        
    }
   
    @IBAction func driverDeclined(_ sender: Any) {
        let query = PFQuery(className: "Trip")
        // query.whereKey("objectId", equalTo: ride.rideID! as String)
        
        query.getObjectInBackground(withId: currTripID!) { (rideFound: PFObject?, error: Error?) -> Void in
            if error == nil && rideFound != nil {
                
                rideFound?.setValue(-1, forKey: "driverResponse")
                rideFound?.saveInBackground()
                
                self.delegate?.returningtoView(tripId: self.currTripID!, response: 1)
                    
                self.navigationController?.popViewController(animated: true)
                
                
            } else {
                
                print("Error: \(String(describing: error))")
            }
        }
    }
    
    @IBAction func driverAccepted(_ sender: Any) {
        let query = PFQuery(className: "Trip")
       // query.whereKey("objectId", equalTo: ride.rideID! as String)
    
        query.getObjectInBackground(withId: currTripID!) { (rideFound: PFObject?, error: Error?) -> Void in
            if error == nil && rideFound != nil {
                
                let innerqry = PFQuery(className: "Ride")
                
                innerqry.getObjectInBackground(withId: self.ride.rideID!) { (curr: PFObject?, error: Error?) -> Void in
                    var seatsRem = self.ride.seatsRemaining
                    seatsRem = seatsRem! - 1
                    
                    curr?.setValue(seatsRem, forKey: "seatsRemaining")
                    curr?.saveInBackground()
                }
                
                
                
                rideFound?.setValue(1, forKey: "driverResponse")
                rideFound?.saveInBackground()
             
                self.delegate?.returningtoView(tripId: self.currTripID!, response: 1)
                self.navigationController?.popViewController(animated: true)

                
            } else {
                
                print("Error: \(String(describing: error))")
            }
        }
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
