//
//  RideViewController.swift
//  KaPool
//
//  Created by Jake Vo on 4/16/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import Parse
import GooglePlaces
import GoogleMaps
import MapKit

class RideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    //var tweetsArray: [Tweet]! = [Tweet]()
    var rides: [Ride]! = [Ride]()
    var trips: [Trip]! = [Trip]()
    
    //@IBOutlet var driverPic: UIImageView!
    
    //@IBOutlet var driverName: UILabel!
    
    var startLocation: CLLocation!
    let defaults = UserDefaults.standard
    var globalValid = false
    
    var currLocName:String?
    
    var locationManager = CLLocationManager()
    var locationLatest:CLLocation!
    
    var searchDest:String = ""
    var searchDept:String = ""

    var signal = 0
    
    var destLoc:CLLocation?
    var originLoc:CLLocation?
    
    var dist1:Double = 0
    
    var dist2:Double = 0
    
    
    var bookCheck = false
    
    //@IBOutlet var tabbar: UITabBar!
    //@IBOutlet var tabbar: UITabBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        var refreshControl = UIRefreshControl()
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Rides Loading")
        refreshControl.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)*/
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        

        locationManager.startUpdatingLocation()
        
        
      //  navigationController?.navigationBar.barTintColor = UIColor(red: 67/255, green: 189/255, blue: 236/255, alpha: 1.0)
      //   tabBarController?.tabBar.barTintColor = UIColor(red: 67/255, green: 189/255, blue: 236/255, alpha: 0.5)

        self.tableView.reloadData()
        
        
        //getData(distance: 0, signal: self.signal)
        // Do any additional setup after loading the view.
    }
    /*
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        
            } */
    
    // SOMETHING TO ADD
    override func viewWillAppear(_ animated: Bool) {
        
        
        //self.tableView.reloadData()
        print ("signal is \(signal)")
        
            var distance:Double = 0.0
            
            if (defaults.object(forKey: "destName") as? String) != nil {
                
                if (defaults.object(forKey: "deptName") as? String) != nil {
                    
                    
                    
                    if let dist = defaults.object(forKey: "distance")  {
                        
                        print ("Here is it \(distance)")
                        
                        
                        
                        if let signalFromFindRide = defaults.object(forKey: "signal") as? Int {
                            
                            self.signal = signalFromFindRide
                            distance = dist as! Double
                            
                            if let originLat = defaults.object(forKey: "originLatitude") {
                                
                                if let originLon = defaults.object(forKey: "originLongtitude") {
                                    
                                    self.originLoc = CLLocation(latitude: originLat as! CLLocationDegrees, longitude: originLon as! CLLocationDegrees)
                                }
                                
                            }
                            
                            if let destLat = defaults.object(forKey: "destLatitude") {
                                
                                
                                if let destLon = defaults.object(forKey: "destLongtitude") {
                                    
                                    self.destLoc = CLLocation(latitude: destLat as! CLLocationDegrees, longitude: destLon as! CLLocationDegrees)
                                    
                                    print ("ok")
                                    getData(signal: self.signal)
                                    self.signal = 0
                                }
                                
                                
                            }
                        }
                    }
                }
                
            }

        
        
        //getData(signal: self.signal)
        //self.signal = 0


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
            
            // SOMETHING TO ADD -- PASS IN THE NEW RIDE
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
        
        locationLatest = locations[locations.count - 1]
        if self.startLocation == nil {
            self.startLocation = locationLatest
            
            //print("startLocation is \(startLocation!)")
            
            let lat = NSNumber(value: startLocation.coordinate.latitude)
            let lon = NSNumber(value: startLocation.coordinate.longitude)
            
            let userLocation: NSDictionary = ["lat": lat, "lon": lon]
            
            
            self.defaults.set(userLocation, forKey: "currentLocation")
            
            self.defaults.synchronize()
            
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
                
                
            })
            
        }
        
        
    }
    
    
   
    

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideCell") as! RideCell
        
        cell.ride = rides[indexPath.row]
        
        
        
        return cell
    }
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return rides.count
    }
    
    // SOMETHING TO ADD
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //performSegue(withIdentifier: "rideDetSegue", sender: UITableViewCell.self)

    }
    
    func getData(signal: Int) {
        
        
        rides.removeAll()
        
        locationManager.stopUpdatingLocation()
        // construct query
        let query = PFQuery(className: "Ride")
        query.limit = 20
        
        
        // fetch data asynchronously
        query.findObjectsInBackground { (ride: [PFObject]?, error: Error?) -> Void in
            
            if let ride = ride {
                // do something with the array of object returned by the call
                
                
                if ride.count > 0  {
                    for i in 0...(ride.count - 1) {


                        
                        let rideTemp = Ride.init(ride[i])
                        
                        //calling from find ride
                        if signal == 1 {
                            
                            let destLocation:CLLocation = CLLocation(latitude: rideTemp.destLat!, longitude: rideTemp.destLon!)
                            let originLocation:CLLocation = CLLocation(latitude: rideTemp.originLat!, longitude: rideTemp.originLon!)

                            
                          
                            self.dist1 = self.calDistance(locOrigin: originLocation, locDest: self.originLoc!)
                            self.dist2 = self.calDistance(locOrigin: destLocation, locDest: self.destLoc!)
                            
                            if self.dist2 < rideTemp.radius! && self.dist1 < rideTemp.radius! {
                                self.rides.append(Ride.init(ride[i]))
                            }
                        }
                        
                    }
                }
                
                self.tableView.reloadData()

                if self.rides.count == 0 {
                    
                    self.alertControl(title: "Kapool", message: "No Ride found!")
                    
                }
                
            } else {
                print(error!)
            }
        }
        
        
        
      
        
    }
    
    func alertControl (title: String, message: String) {
        
        let alertControler = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        //button in alert box
        alertControler.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alertControler, animated: true, completion: nil)
    }
    
    func calDistance(locOrigin: CLLocation, locDest: CLLocation) -> Double {
        
        let distanceInMeters = locOrigin.distance(from: locDest)
        
        //print("inside calDistance)")
        
        let miles = ((Double)(distanceInMeters)) / 1609.0
        
        
        
        return miles
        
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "rideDetSegue" {
            let rideCell = sender as! RideCell
            let rideDeets = segue.destination as! RideDetailsVC
            rideDeets.curr = rideCell.ride
            rideDeets.origCoordinates = rideCell.origCoordinates
            rideDeets.destCoordinates = rideCell.destCoordinates
            
            rideDeets.ogName = rideCell.fromText.text
            rideDeets.destName = rideCell.toText.text
            
            
        }
    }
    
    
}



