//
//  RiderViewController.swift
//  Uber
//
//  Created by Nasr Mohammed on 6/27/19.
//  Copyright © 2019 Nasr Mohammed. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callAnUberButton: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocatin = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    var driverLocation = CLLocationCoordinate2D()
    var driverOnTheWay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // check not to have dublicate request
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in

                self.uberHasBeenCalled = true
                self.callAnUberButton.setTitle("Cancel Uber", for: .normal)
                
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                if let rideRequestDictoinary = snapshot.value as? [String:AnyObject] {
                    if let driverLat = rideRequestDictoinary["driverLat"] as? Double  {
                        if let driverLon = rideRequestDictoinary["driverLon"] as? Double {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                        }
                    }
                }

            }
        }

    }
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocatin.latitude, longitude: userLocatin.latitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundDistance = round(distance * 100) / 100
        callAnUberButton.setTitle("Your driver is \(roundDistance)km away!", for: .normal)
        map.removeAnnotation(map!.annotations as! MKAnnotation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // to get the user location
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            // get the actual location
            userLocatin = center
            let region = MKCoordinateRegion (center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            map.setRegion(region, animated: true)
            
            // go get the current user location
            map.removeAnnotations(map.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your location"
            map.addAnnotation(annotation)
            
        }
    }
    @IBAction func callUberTapped(_ sender: Any) {
        if driverOnTheWay {
        if let email = Auth.auth().currentUser?.email {
            
            if uberHasBeenCalled {
                uberHasBeenCalled = false
                callAnUberButton.setTitle("Call an Uber", for: .normal)
                
                // remove the user when cancel an uber
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                    snapshot.ref.removeValue()
                    Database.database().reference().child("RideRequests").removeAllObservers()
                }
            } else {
                let rideRequestDictionary : [String : Any] = ["email":email,"lat":userLocatin.latitude,"lon":userLocatin.longitude]
                Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                
                uberHasBeenCalled = true
                callAnUberButton.setTitle("Cancel Uber", for: .normal)
            }
            
            }
        }
    }
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
