//
//  DriverTableViewController.swift
//  
//
//  Created by Nasr Mohammed on 7/5/19.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class DriverTableViewController: UITableViewController {

    var rideRequests : [DataSnapshot] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            self.rideRequests.append(snapshot)
            self.tableView.reloadData()
            
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
                cell.textLabel?.text = email
            }
        }
        
        return cell
    }
    

}
