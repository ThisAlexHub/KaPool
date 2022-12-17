//
//  OfferRideVC.swift
//  KaPool
//
//  Created by Madel Asistio on 4/19/17.
//  Copyright © 2017 Madel Asistio. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class OfferRideVC: UIViewController, CLLocationManagerDelegate, SelectDateViewControllerDelegate{
    
    /* labels to input in the database 
     * price: Double
     * seatAvail: Int
     * toLoc: GMSPlace
     * fromLoc: GMSPlace
     * departDate: Date
     */
    @IBOutlet weak var scrollView: UIScrollView!
    
 
    @IBOutlet weak var seatView: UIView!
    // label variables
    @IBOutlet weak var dateLabel: UILabel!
    var departDate: Date!
    @IBOutlet weak var seatTextField: UITextField!
    var seatAvail: Int = 0
    
    @IBOutlet weak var radiusTextField: UITextField!
    var radius: Double = 0.0
    
    
    @IBOutlet var priceText: UITextField!
    let formatter = NumberFormatter()
    
    
    // place variables
    @IBOutlet weak var frmBttn: UIButton!
    @IBOutlet weak var toBttn: UIButton!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapViewPlaces: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 17.0
    
    var likelyPlaces: [GMSPlace] = []
    var currPlace: GMSPlace?
    var placeSelected: GMSPlace?

    var toLoc: GMSPlace?
    var frmLoc: GMSPlace?
    var toFlag: Int = 0
    var fromFlag: Int = 0
        // map variables
    @IBOutlet weak var mapView: GMSMapView!

    var originLat:CLLocationDegrees?
    var originLon:CLLocationDegrees?
    
    var destLat:CLLocationDegrees?
    var destLon:CLLocationDegrees?

    override func viewDidLoad() {
        super.viewDidLoad()
        /* HANDLES KEYBOARD */
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        /* END HANDLE KEY */
        
        
        /* LOAD PLACES */
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        /* END LOAD PLACES*/
        
        
        /* add default date */
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy  h:mm a"
        let currDate = dateFormatter.string(from: Date())
        departDate = Date()
       // print("DEPART DATE IS \(departDate)")
     
        
        dateLabel.text = currDate
    }
    @IBAction func cancelPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func dismissKB(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    // HANDLES KEYBOARD
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= (keyboardSize.height - (self.seatView.frame.height))
            }
            
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            scrollView.isScrollEnabled = true
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += (keyboardSize.height - (self.seatView.frame.height))
            }
            let contentInsets = UIEdgeInsets()
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            scrollView.isScrollEnabled = true
        }
    }
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location.coordinate)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.map = self.mapView
    
        
        listLikelyPlaces()
        
        /* DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
         
         self.fromBttn.setTitle(self.currPlace?.name, for: .normal)
         // Put your code which should be executed with a delay here
         }) */
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    @IBAction func searchLocation(_ sender: UIButton) {
        
        self.toFlag = 0
        self.fromFlag = 0
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only addresses.
        let addressFilter = GMSAutocompleteFilter()
        addressFilter.type = .address
        autocompleteController.autocompleteFilter = addressFilter
        
        if (sender.restorationIdentifier == "toLoc") {
            self.toFlag = 1
            /*
             print (self.toLoc?.name)
             
             self.ToBttn.setTitle(self.toLoc?.name, for: .normal)*/
            
        } else {
            self.fromFlag = 1
        }
        
        present(autocompleteController, animated: true, completion: {})

    }
    
    func changeDepTime(_ dateChosen: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy  h:mm a"
        departDate = dateFormatter.date(from: dateChosen)
      
        //dateChosen.minimum
        //print("CHANGED DEPART DATE IS \(departDate)")

        dateLabel.text = dateChosen
      
      if (departDate>Date()){
         print(dateLabel.text!)
      }else{
        dateLabel.text = dateFormatter.string(from: Date())
        print("nah")
        let alert1 = UIAlertView()
        alert1.title = "Alert"
        alert1.message = "wrong date!!!"
        alert1.addButton(withTitle: "Understood")
        alert1.show()
        
        
      
      }
      

      
    }
    
    
    @IBAction func goBttnClicked(_ sender: Any) {
      
       
        var price:Double?
        
        if (priceText.text?.isEmpty == false) {
            print("Iam here")
            price = Double(priceText.text!) ?? 0.0
            //formatter.numberStyle = .currency
            //priceText.text = formatter.string(from: price! as NSNumber)
            
            print ("The price is \(priceText.text!)")

        }
    
        
      if (toLoc == nil){
        let alert2 = UIAlertView()
        alert2.title = "Alert"
        alert2.message = "please set the date!!!"
        alert2.addButton(withTitle: "Understood")
        alert2.show()
        
        print(departDate.timeIntervalSinceReferenceDate)
        
        
      }
      
      else if (seatAvail > 4){
        let alert3 = UIAlertView()
        alert3.title = "Alert"
        alert3.message = "4 seats only!!!"
        alert3.addButton(withTitle: "Understood")
        alert3.show()
        
        
        
      }
      else if (price! < 0.01){
        print(priceText.text!)
        let alert4 = UIAlertView()
        alert4.title = "Alert"
        alert4.message = "please add at least 1 cent!!"
        alert4.addButton(withTitle: "Understood")
        alert4.show()
        
      } else if radiusTextField.text?.isEmpty == true {
        
        let alert5 = UIAlertView()
        alert5.title = "Alertxxx"
        alert5.message = "please add at least 1 cent!!"
        alert5.addButton(withTitle: "Understood")
        alert5.show()

      } else {
        
        radius = (Double) (radiusTextField.text!)!
        
        Ride.addRide(destination: toLoc, origin: frmLoc, radius: radius, originLat: self.originLat, originLon: originLon, destLat: destLat, destLon: destLon, price: price, departDate: departDate, seats: seatAvail) { (success: Bool, error: Error?) in
          print("ride added from go")
          
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        
        
        self.present(vc, animated: true, completion: nil)
      }
    }
  
    
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
            
            self.currPlace = self.likelyPlaces[0]
            self.frmLoc = self.currPlace
            //print("CURRPLACE IS \(self.currPlace!)")
            
        })
    }
    
    
    @IBAction func editedSeatCount(_ sender: Any) {
      
      if (Int(seatTextField.text!)!<5){
        self.seatAvail = Int(seatTextField.text!) ?? 0
    
        print("changed seat")
      }else{
        seatTextField.text=String(4)
        self.seatAvail = Int(seatTextField.text!) ?? 0
        let alert = UIAlertController(title: "Alert", message: "It be should 4 or less seats", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }

    }
   // @IBAction func doneEditing(_ sender: Any) {
        
     //   if (priceTextField.text != nil) {
       //     self.price = Double(priceTextField.text!) ?? 0.0
         //   formatter.numberStyle = .currency
           // priceTextField.text = formatter.string(from: price as NSNumber)
        //}
    //}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let dateVC = segue.destination as! SelectDateViewController
        dateVC.delegate = self
    }
 

}

extension OfferRideVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Print place info to the console.
        print("Place name: \(place.name)")
        print("Place address: \((String) (describing: place.formattedAddress!))")
        //print("Place attributions: \(place.attributions)")
        
        //self.placeSelected = place
        
        
        if (self.toFlag == 1) {
            self.toLoc = place
            
           // print (self.toLoc?.name)
            
            self.toBttn.setTitle(self.toLoc?.name, for: .normal)
            self.toBttn.setTitleColor(UIColor.blue, for: .normal)
            
            self.originLat = place.coordinate.latitude
            self.originLon = place.coordinate.longitude
            
        } else {
            self.frmLoc = place
            
           // print (self.frmLoc?.name)
            
            
            self.frmBttn.setTitle(self.frmLoc?.name, for: .normal)
            
            self.frmBttn.setTitleColor(UIColor.blue, for: .normal)
            
            self.destLat = place.coordinate.latitude
            self.destLon = place.coordinate.longitude
            
            
        }
        /*
        // Get the address components.
        if let addressLines = place.addressComponents {
            // Populate all of the address fields we can find.
            for field in addressLines {
                switch field.type {
                case kGMSPlaceTypeStreetNumber:
                    street_number = field.name
                case kGMSPlaceTypeRoute:
                    route = field.name
                case kGMSPlaceTypeNeighborhood:
                    neighborhood = field.name
                case kGMSPlaceTypeLocality:
                    locality = field.name
                case kGMSPlaceTypeAdministrativeAreaLevel1:
                    administrative_area_level_1 = field.name
                case kGMSPlaceTypeCountry:
                    country = field.name
                case kGMSPlaceTypePostalCode:
                    postal_code = field.name
                case kGMSPlaceTypePostalCodeSuffix:
                    postal_code_suffix = field.name
                // Print the items we aren't using.
                default:
                    print("Type: \(field.type), Name: \(field.name)")
                }
            }
        } */
        
        // Call custom function to populate the address form.
   //     fillAddressForm()
        
        // Close the autocomplete widget.
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Show the network activity indicator.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    // Hide the network activity indicator.
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


