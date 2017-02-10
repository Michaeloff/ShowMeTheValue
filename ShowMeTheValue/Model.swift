//
//  Model.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/19/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

import SwiftyJSON

// Class used here instead of Struct as it is desired for PropertyObject to be passed by reference.
class PropertyObject {
    var displayableAddress = ""
    var street = ""
    var city = ""
    var state = ""
    var zip = ""
    var zpid = ""
    var latitude = ""
    var longitude = ""
    var estimate = ""
    var oneMonthChange = ""
    var lastSoldDate = ""
    var lastSoldPrice = ""
    var localRegionAverage = ""
    var yearBuilt = ""
    var squareFeet = ""
    var lotSquareFeet = ""
    var numOfBathrooms = ""
    var numOfBedrooms = ""
    var type = ""
    var parkingType = ""
    var parkingSpaces = ""
    var homeDetailsZillowURL = ""
    var errorCode = ""
    var zillowHomeImageURL: URL?
    var googleStreetViewImageURL: URL?
    
    func reset() {
        displayableAddress = ""
        street = ""
        city = ""
        state = ""
        zip = ""
        zpid = ""
        latitude = ""
        longitude = ""
        estimate = ""
        oneMonthChange = ""
        lastSoldDate = ""
        lastSoldPrice = ""
        localRegionAverage = ""
        yearBuilt = "N/A"
        squareFeet = "N/A"
        lotSquareFeet = "N/A"
        numOfBathrooms = "N/A"
        numOfBedrooms = "N/A"
        type = "N/A"
        parkingType = "N/A"
        parkingSpaces = ""
        homeDetailsZillowURL = "http://www.zillow.com/"
        errorCode = ""
        zillowHomeImageURL = nil
        googleStreetViewImageURL = nil
    }
}

class LocationObject {
    var formattedAddress: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var streetNum = ""
    var streetName = ""
    var zip = ""
    var addressToQuery = ""
    
    required init(json: JSON) {
        formattedAddress = json["formatted_address"].stringValue
        latitude = json["geometry"]["location"]["lat"].doubleValue
        longitude = json["geometry"]["location"]["lng"].doubleValue
        
        if let addressComponents = json["address_components"].array {
            for addressComponent in addressComponents {
                if let types =  addressComponent["types"].array {
                    for type in types {
                        switch type.stringValue {
                            case "street_number":
                                streetNum = addressComponent["long_name"].stringValue
                            case "route":
                                streetName = addressComponent["long_name"].stringValue
                            case "postal_code":
                                zip = addressComponent["long_name"].stringValue
                            default: ()
                        }
                    }
                }
            }
        }
        addressToQuery = streetNum + " " + streetName + ", " + zip
    }
}
