//
//  RideDetailsVC.swift
//  KaPool
//
//  Created by Madel Asistio on 5/21/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Parse

class RideDetailsVC: UIViewController, GMSMapViewDelegate {
    
    
    @IBOutlet weak var destLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var estDurLabel: UILabel!
    @IBOutlet weak var avgRespLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressView: UIView!
    
    var destCoordinates: CLLocationCoordinate2D!
    var origCoordinates: CLLocationCoordinate2D!
    
    var curr: Ride!
    var destName: String!
    var ogName: String!
    
    var user: User!
    
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.priceLabel.text = String(format:"$%.0f", curr.price!)
        
        self.dateLabel.text = curr.departDate?.toString(dateFormat: "MMM d, yyyy  h:mm a")
        self.seatsLabel.text = "\(curr.seatsRemaining!)/\(curr.seats!)"
            

        self.originLabel.text = ogName
        self.destLabel.text = destName
        
        self.addMap { () -> () in
            self.fixLocViews()
        }
        print (curr.driver)
        User.getUser(userid: curr.driver) { (user: User) in
            
            self.user = user
            self.userLabel.text = user.username
            
        } 
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func riderAccepted(_ sender: Any) {
        
        //if ()
        // check if rider id == driver id, if  true delete
  //      let locDict = defaults.object(forKey: "currentLocation") as? NSDictionary
        
        print("I am testing")
        let lat = defaults.object(forKey: "originLatitude") as! CLLocationDegrees
        
        let lon = defaults.object(forKey: "originLongtitude") as! CLLocationDegrees
        
        let userLocation:CLLocation = CLLocation(latitude: lat, longitude: lon)
        
        let name = "Test"
            //TODO: locDict?.object(forKey: "deptName") as? String
        
        Trip.addTrip(rideid: curr.rideID!,pickupName: name, pickupLocation: userLocation,
                     driverAccepted: false, riderid: (PFUser.current()?.objectId)!, driverid: curr.driver ) {
                        (sucess: Bool, error: Error?) in
                        
                        if ((error) != nil) {
                            print (error!)
                            
                        } else {
                            print ("trip added")
                            
                        }
                        
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func rideDeclined(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func addMap(handleComplete:@escaping (()->())) {
        
        let camera = GMSCameraPosition.camera(withLatitude: origCoordinates.latitude,
                                              longitude: origCoordinates.longitude,
                                              zoom: 5)
        mapView.camera = camera
        mapView.delegate = self
        
        let path = GMSMutablePath()
        
        var bounds = GMSCoordinateBounds()
        
        let ogMarker = GMSMarker()
        ogMarker.position = CLLocationCoordinate2D(latitude: origCoordinates.latitude, longitude: origCoordinates.longitude)
        ogMarker.map = self.mapView
        ogMarker.title = ogName
        ogMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        
        
        let destMarker = GMSMarker()
        destMarker.position = CLLocationCoordinate2D(latitude: destCoordinates.latitude, longitude: destCoordinates.longitude)
        destMarker.map = self.mapView
        
        destMarker.title = destName
        destMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        
        path.add(origCoordinates)
        path.add(destCoordinates)
        
        
        bounds = bounds.includingCoordinate(ogMarker.position)
        bounds = bounds.includingCoordinate(destMarker.position)
        
        Map.fetchMapData(mapView: mapView, from: ogMarker.position, to: destMarker.position) { (totalSecs: Int) in
            
    
            self.estDurLabel.text = Map.stringifyDur(totalDurInSec: totalSecs)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
            // mapView.animate(with: update)
            self.mapView.animate(with: update)
            
            handleComplete()
            
        }
    }
    
    
    func fixLocViews() {
        
        self.mapView.bringSubview(toFront: self.addressView)
        self.addressView.layer.shadowColor = UIColor.black.cgColor
        self.addressView.layer.shadowOpacity = 0.5
        self.addressView.layer.shadowOffset = CGSize(width: -1, height: 1)
        
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
