//
//  RideViewController.swift
//  KaPool
//
//  Created by Jake Vo on 4/16/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//
/*
import UIKit
import Parse
import GooglePlaces
import GoogleMaps
import MapKit

class RideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    //var tweetsArray: [Tweet]! = [Tweet]()
    var rides: [Ride]! = [Ride]()
    
    var startLocation: CLLocation!
    let defaults = UserDefaults.standard
    
    
    var currLocName:String?
    
    var locationManager = CLLocationManager()
    var locationLatest:CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //getData()
        
        // Do any additional setup after loading the view.
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            // User has granted autorization to location, get location
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func onOfferRide(_ sender: Any) {
        
        if PFUser.current() != nil {
            //let offerRide = storyboard.instantiateViewController(withIdentifier: "offerRide") as! UITabBarController
            //window?.rootViewController = offerRide
            let vc = storyboard?.instantiateViewController(withIdentifier: "offerRide") as! OfferRideVC
            
            self.present(vc, animated: true, completion: nil)
            
        } else {
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "loginPage") as! SigninViewController
            vc.signal = "offer"
            
            self.present(vc, animated: true, completion: nil)
            
            
        }
    }
    
    /*
     get user current location
     convert it into place name
     then comapre if the places in ride array are close to this place
     */
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("I am here")
        
        
        locationLatest = locations[locations.count - 1]
        if self.startLocation == nil {
            self.startLocation = locationLatest
            
            defaults.set(startLocation.coordinate.latitude, forKey: "latitude")
            defaults.set(startLocation.coordinate.longitude, forKey: "longitude")
            
            
            CLGeocoder().reverseGeocodeLocation(startLocation, completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    
                    print(error!)
                    
                } else {
                    
                    if let placemark = placemarks?[0] {
                        
                        var address = ""
                        if placemark.subThoroughfare != nil {
                            
                            address += placemark.subThoroughfare! + " "
                        }
                        
                        if placemark.thoroughfare != nil {
                            
                            address += placemark.thoroughfare! + "?"
                            
                        }
                        
                        self.currLocName = address
                    }
                    
                }
                self.getData(currLocName: self.currLocName!)
                
            })
            
        }
        
        
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideCell") as! RideCell
        
        cell.ride = rides[indexPath.row]
        
        return cell
    }
    
    func showRideAround(originName: String) -> Bool {
        
        
        
        //let token = "AIzaSyA2UuVKx6XIhxAzoNlEWXJcbLS0Jqx8qDI"
        let valid = false
        
        print(originName)
        
        //print("current loc is \(self.currLocName)")
        
        //
        //locationManager.stopUpdatingLocation()
        
        
        return valid
        
        
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return rides.count
    }
    
    func getData(currLocName: String) {
        
        
        locationManager.stopUpdatingLocation()
        // construct query
        let query = PFQuery(className: "Ride")
        query.limit = 20
        
        // fetch data asynchronously
        query.findObjectsInBackground { (ride: [PFObject]?, error: Error?) -> Void in
            if let ride = ride {
                // do something with the array of object returned by the call
                
                if ride.count > 0 {
                    
                    for i in (0...ride.count-1).reversed() {
                        
                        self.rides.append(Ride.init(ride[i]))
                        
                        print (self.showRideAround(originName: "56th San Diego"))
                        
                    }
                }
                
                
                
                //self.tableView.reloadData()
                // self.instaPosts = posts
                
                
            } else {
                print(error!)
            }
        }
        
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
*/
