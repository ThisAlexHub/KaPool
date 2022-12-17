//
//  FindRideViewController.swift
//  KaPool
//
//  Created by  Alex Sumak on 4/17/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import MapKit




class FindRideViewController: UIViewController {
  
    @IBOutlet var searchDept: UITextField!
    @IBOutlet var searchDest: UITextField!
    
    
    
    var signal = 0
    var distance: Double?
    
    var locOrigin:CLLocation?
    
    var locDest:CLLocation?
    
    @IBOutlet var currentLoc: UIImageView!
    
    let defaults = UserDefaults.standard
    
    var startLocation: CLLocation!
    
    @IBOutlet var tabbar: UIView!
    @IBOutlet var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //tabbar.isHidden = false
        searchDest.addTarget(self, action: #selector(onDestination), for: .touchDown)
        
        searchDept.addTarget(self, action: #selector(onDeparture), for: .touchDown)
        
        addTapGesture()
        searchButton.isEnabled = false
        searchButton.layer.cornerRadius = 5
        searchButton.layer.borderWidth = 1
        
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 1
        
        searchButton.backgroundColor = hexStringToUIColor(hex: "#B8B8B8")
    }
    
    
    func addTapGesture(){
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(FindRideViewController.clickedCurrentIcon(_:)))
        currentLoc.isUserInteractionEnabled = true
        currentLoc.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func clickedCurrentIcon(_ sender: UITapGestureRecognizer){
        
        
        let locDict = defaults.object(forKey: "currentLocation") as? NSDictionary
        
        print("I am testing")
        let lat = locDict?.object(forKey: "lat") as! CLLocationDegrees
        
        let lon = locDict?.object(forKey: "lon") as! CLLocationDegrees
        
        let userLocation:CLLocation = CLLocation(latitude: lat, longitude: lon)
        
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                
                print(error!)
                
            } else {
                
                if let placemark = placemarks?[0] {
                    
                    var address = ""
                    if placemark.subThoroughfare != nil {
                        
                        address += placemark.subThoroughfare! + " "
                    }
                    
                    if placemark.thoroughfare != nil {
                        
                        address += placemark.thoroughfare!
                        
                    }
                    //set current location when user clicks on the gps icon
                    self.searchDept.text = address
                    self.locOrigin = userLocation
                }
                
            }
            
            
        })
        
        
        
    }
    
    
    
    
    
    func onDestination() {
        
        signal = 2
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only addresses.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        autocompleteController.primaryTextColor = UIColor.blue
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    func onDeparture() {
        
        
        signal = 1
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only addresses.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        autocompleteController.primaryTextColor = UIColor.blue
        present(autocompleteController, animated: true, completion: nil)

    }

    @IBOutlet var searchButton: UIButton!
    
    
    @IBAction func onSearch(_ sender: Any) {
        
        
        //self.delegate?.doneSearch(searchDept.text!, searchDest.text!)
        
        
        defaults.set(searchDest.text, forKey: "destName")
        defaults.set(searchDept.text, forKey: "deptName")
        //print ("Distance in miles is \(calDistance(dept: searchDept.text!, dest: searchDest.text!))")
        
        print ("here")
        defaults.set(locOrigin?.coordinate.latitude, forKey: "originLatitude")
        defaults.set(locOrigin?.coordinate.longitude, forKey: "originLongtitude")
        
        calDistance()
        
        defaults.set(locDest?.coordinate.latitude, forKey: "destLatitude")
        defaults.set(locDest?.coordinate.longitude, forKey: "destLongtitude")
        
        
        
        
        defaults.set(1, forKey: "signal")
        
        defaults.synchronize()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func calDistance()  {
        
        let distanceInMeters = locOrigin?.distance(from: locDest!)
        
        defaults.set(distanceInMeters!/1609, forKey: "distance")
        print("distance from find ride\(distanceInMeters!/1609)")
        
        
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    
}



extension FindRideViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    

        dismiss(animated: true, completion: nil)
        let address1 = (place.formattedAddress?.components(separatedBy: ",")[0])! + " "
        let address2 = (place.formattedAddress?.components(separatedBy: ",")[1])! + " "
        let address3 = (place.formattedAddress?.components(separatedBy: ",")[2])!
        
        if signal == 1 {
            searchDept.text = address1 + address2 + address3
            locOrigin = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
            
        } else {
            searchDest.text = address1 + address2 + address3
            locDest = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        signal = 0
        searchButton.isEnabled = true
        searchButton.backgroundColor = hexStringToUIColor(hex: "#F99D52")
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
