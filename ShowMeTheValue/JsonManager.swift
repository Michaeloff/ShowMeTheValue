//
//  JsonManager.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/19/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

import SwiftyJSON

class JsonManager {
    
    // Uses Google Geocode to lookup a U.S. street address by latitude and longitude.
    // Example: "https://maps.googleapis.com/maps/api/geocode/json?latlng=47.637933,-122.347938&key=AIzaSyAw39qx0_hpB9D1qbYOjQxPAfw69Uitwxg"
    // Returns (among other things): "formatted_address" : "2114 Bigelow Ave N, Seattle, WA 98109, USA"
    // Lat/Long:    Google Geocode: 47.6379364, -122.3479871   Zillow: 47.637933, -122.347938

    static let geocodeBaseURL = "https://maps.googleapis.com/maps/api/geocode/json"
    static let myGeocodeKey = "AIzaSyAw39qx0_hpB9D1qbYOjQxPAfw69Uitwxg"
    static var locationItems = [LocationObject]()
    
    static func lookupAddressByLatLong(latitude: Double, longitude: Double, onCompletion: @escaping (String) -> Void) {
        let route = geocodeBaseURL + "?latlng=" + String(latitude) + "," + String(longitude) + "&key=" + myGeocodeKey

        RestApiManager.sharedInstance.makeHTTPGetRequestJSON(path: route, onCompletion: { json, err in
            if let results = json["results"].array {
                if results.count > 0 { self.locationItems.append(LocationObject(json: results[0])) }
                DispatchQueue.main.async(execute: { onCompletion("") })
            } else {
                var errorText = "The Internet connection appears to be offline."
                if let errorReturned = err?.localizedDescription { errorText = errorReturned }
                DispatchQueue.main.async(execute: { onCompletion(errorText) })
            }
        })
    }

    static let streetViewMetadataBaseURL = "https://maps.googleapis.com/maps/api/streetview/metadata?size=600x300&location="
    static let streetViewBaseURL = "https://maps.googleapis.com/maps/api/streetview?size=600x300&location="
    static let myStreetViewKey = "AIzaSyC9zvwgQmPg2P1dSGk_0TJ8ZwdLykihJwk"

    // Examples: metadata with "OK" status, then a successful image download.
    // https://maps.googleapis.com/maps/api/streetview/metadata?size=600x300&location=47.6379364,-122.3479871&key=AIzaSyC9zvwgQmPg2P1dSGk_0TJ8ZwdLykihJwk
    // https://maps.googleapis.com/maps/api/streetview?size=600x300&location=47.6379364,-122.3479871&key=AIzaSyC9zvwgQmPg2P1dSGk_0TJ8ZwdLykihJwk
    
    // Examples: metadata with "ZERO_STATUS" status, then a "Sorry, we have no imagery here" image download
    // https://maps.googleapis.com/maps/api/streetview/metadata?size=600x300&location=47.6374,-132.3479871&key=AIzaSyC9zvwgQmPg2P1dSGk_0TJ8ZwdLykihJwk
    // https://maps.googleapis.com/maps/api/streetview?size=600x300&location=47.6374,-132.3479871&key=AIzaSyC9zvwgQmPg2P1dSGk_0TJ8ZwdLykihJwk
    
    static func getStreetViewMetaData(latitude: String, longitude: String, onCompletion: @escaping (String) -> Void) {
        var route = streetViewMetadataBaseURL + latitude + "," + longitude + "&key=" + myStreetViewKey

        // Get street view metadata to confirm street view is available at this lat/long
        RestApiManager.sharedInstance.makeHTTPGetRequestJSON(path: route, onCompletion: { json, err in
            route = ""
            if json["status"] == "OK" {
                // Street view is available. Return URL to use to retrieve street view image. This URL returns image directly, not JSON or XML.
                route = streetViewBaseURL + latitude + "," + longitude + "&key=" + myStreetViewKey
            }
            onCompletion(route)
        })
    }
}


