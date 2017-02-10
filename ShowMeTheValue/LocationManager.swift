//
//  LocationManager.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/18/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {

    static let sharedInstance = LocationManager()  // Singleton. Only one location manager desired.
    let locationManager = CLLocationManager()
    var locationCheckingAuthorized = false
    var notifyLocationIsAuthorized: (() -> Void)?
    
    func locationInit() {
        locationManager.delegate = self
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationCheckingAuthorized = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            if let authorizedCallback = notifyLocationIsAuthorized {
                authorizedCallback()
            }
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationCheckingAuthorized = false
            if let authorizedCallback = notifyLocationIsAuthorized {
                authorizedCallback()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Process the received location update
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error")
    }
    
    // locationManager.requestLocation()  // Force a location update. Can take 10 seconds before didUpdateLocations is called
}


