//
//  StartingViewController.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 11/15/16.
//  Copyright © 2016 David Michaeloff. All rights reserved.
//

// Apple CLLocation:
// 1) Update Info.plist
//      a) Privacy - Location When In Use Usage Description
//      b) Privacy - Location Always Usage Description
// 2) Check for authorization

// MY Zillow Web Services Identification (ZWSID) is: X1-ZWz1fgxn8cq7m3_8469v  (Use ZWSID for all Zillow API calls.)
// Zillow API information and documentation here:
// http://www.zillow.com/howto/api/APIOverview.htm?utm_source=email&utm_medium=email&utm_campaign=emo-apiregistration-api
// Example: http://www.zillow.com/webservice/GetZestimate.htm?zws-id=X1-ZWz1fgxn8cq7m3_8469v&zpid=48749425

import UIKit
import MapKit

class StartingViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segControlMapHybridSatellite: UISegmentedControl!
    let regionRadius: CLLocationDistance = 50
    var mapInitialized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segControlMapHybridSatellite.layer.cornerRadius = 7.0
        LocationManager.sharedInstance.notifyLocationIsAuthorized = { () -> Void in self.locationUpdatesAuthorized() }
        LocationManager.sharedInstance.locationInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mapInitialized {
            centerMapOnCurrentLocation()
        }
    }
    
    func locationUpdatesAuthorized() {
        if !LocationManager.sharedInstance.locationCheckingAuthorized {
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to provide local home estimates, please open this app's settings and set location access to 'While Using the App'.",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url as URL)
                }
            }
            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        initMap()
    }
    
    func initMap() {
        guard let currentLocation = LocationManager.sharedInstance.locationManager.location else { return }
        mapView.mapType = MKMapType.hybrid
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        mapInitialized = true
    }
    
    func centerMapOnCurrentLocation() {
        guard let currentLocation = LocationManager.sharedInstance.locationManager.location else { return }
        
        // Setting region instead of "mapView.setCenter(currentLocation.coordinate, animated: true)" maintains user zoom level
        var regionCurrentLocationCentered = mapView.region
        regionCurrentLocationCentered.center = currentLocation.coordinate
        mapView.setRegion(regionCurrentLocationCentered, animated: true)
    }
    
    @IBAction func buttonCenterMapTouched(_ sender: UIButton) {
        centerMapOnCurrentLocation()
    }
    
    @IBAction func segControlSelectionChanged(_ sender: UISegmentedControl) {
        switch segControlMapHybridSatellite.selectedSegmentIndex {
        case 0: mapView.mapType = MKMapType.standard
        case 1: mapView.mapType = MKMapType.hybrid
        case 2: mapView.mapType = MKMapType.satellite
        default: () // "satelliteFlyover" and "hybridFlyover" are also options
        }
    }
}
