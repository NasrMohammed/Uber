//
//  DriverTableViewController.swift
//  
//
//  Created by Nasr Mohammed on 7/5/19.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {

    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            self.rideRequests.append(snapshot)
            self.tableView.reloadData()
        }
        // Reload the table view every 3 seconds
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            driverLocation = coord
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideRequests.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)

        let snapshot = rideRequests[indexPath.row]
        
        if let rideRequestDictoinary = snapshot.value as? [String:AnyObject] {
            if let email = rideRequestDictoinary["email"] as? String {
                if let lat = rideRequestDictoinary["lat"] as? Double {
                    if let lon = rideRequestDictoinary["lon"] as? Double {
                        
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                        
                        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                        let roundDistance = round(distance * 100) / 100
                        cell.textLabel?.text = "\(email) - \(roundDistance) km away"
                    }
                }
                
            }
        }
        
        return cell
    }
    // accept the request
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequests[indexPath.row]

        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptRequestViewController {
            
            if let snapshot = sender as? DataSnapshot {
                if let rideRequestDictoinary = snapshot.value as? [String:AnyObject] {
                    if let email = rideRequestDictoinary["email"] as? String {
                        if let lat = rideRequestDictoinary["lat"] as? Double {
                            if let lon = rideRequestDictoinary["lon"] as? Double {
                                acceptVC.requestEmail = email
                                
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon )
                                acceptVC.requestLocation = location

                            }
                        }
                    }
                }
            }
        }
    }

}
