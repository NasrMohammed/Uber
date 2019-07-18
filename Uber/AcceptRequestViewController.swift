//
//  AcceptRequestViewController.swift
//  Uber
//
//  Created by Nasr Mohammed on 7/18/19.
//  Copyright © 2019 Nasr Mohammed. All rights reserved.
//

import UIKit
import MapKit

class AcceptRequestViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    

    @IBAction func acceptTapped(_ sender: Any) {
    }
    
}
