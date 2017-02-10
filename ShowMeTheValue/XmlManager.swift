//
//  XmlManager.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/19/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

import AEXML

class XmlManager {

    static let myZillowKey = "X1-ZWz1fgxn8cq7m3_8469v"
    static let getDeepSearchResultsBaseURL = "http://www.zillow.com/webservice/GetDeepSearchResults.htm?zws-id="
    static let getUpdatedPropertyDetails = "http://www.zillow.com/webservice/GetUpdatedPropertyDetails.htm?zws-id="
    
    static func getDeepSearchResults(property: PropertyObject, onCompletion: @escaping (Data?) -> Void) {
        //Examples (With zip vs city/state):
        // http://www.zillow.com/webservice/GetDeepSearchResults.htm?zws-id=X1-ZWz1fgxn8cq7m3_8469v&address=2114+Bigelow+Ave&citystatezip=98109
        // http://www.zillow.com/webservice/GetDeepSearchResults.htm?zws-id=X1-ZWz1fgxn8cq7m3_8469v&address=2114+Bigelow+Ave&citystatezip=Seattle%2C+WA
        
        let addressWithPluses = property.street.replacingOccurrences(of: " ", with: "+")
        let route = getDeepSearchResultsBaseURL + myZillowKey + "&address=" + addressWithPluses + "&citystatezip="
        var cityStateZip = ""
        if property.zip != "" {
            cityStateZip = property.zip
        }
        else {
            cityStateZip = property.city + "%2C+" + property.state
        }
        let finalRoute = route + cityStateZip
        
        RestApiManager.sharedInstance.makeHTTPGetRequestXML(path: finalRoute, onCompletion: { xmlData, error in
            onCompletion(xmlData)
        })
    }
    
    static func getUpdatedPropertyDetails(zpid: String, onCompletion: @escaping (Data?) -> Void) {
        //Example: http://www.zillow.com/webservice/GetUpdatedPropertyDetails.htm?zws-id=X1-ZWz1fgxn8cq7m3_8469v&zpid=48749425
        let route = getUpdatedPropertyDetails + myZillowKey + "&zpid=" + zpid

        RestApiManager.sharedInstance.makeHTTPGetRequestXML(path: route, onCompletion: { xmlData, error in
            onCompletion(xmlData)
        })
    }
    
    static func parseDeepSearchResults(xmlData: Data?, property: PropertyObject) {
        guard
            let xmlData = xmlData
            else { return }
        
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlData)
            
            if let errorCode = xmlDoc.root["message"]["code"].value {
                property.errorCode = errorCode
                if errorCode != "0" {
                    return
                }
            }
            
            if let zpid = xmlDoc.root["response"]["results"]["result"]["zpid"].value {
                property.zpid = zpid
            }

            if let latitude = xmlDoc.root["response"]["results"]["result"]["address"]["latitude"].value {
                property.latitude = latitude
            }
            
            if let longitude = xmlDoc.root["response"]["results"]["result"]["address"]["longitude"].value {
                property.longitude = longitude
            }
            
            if let zestimate = xmlDoc.root["response"]["results"]["result"]["zestimate"]["amount"].value {
                property.estimate = zestimate
            }
            
            if let oneMonthChange = xmlDoc.root["response"]["results"]["result"]["zestimate"]["valueChange"].value {
                property.oneMonthChange = oneMonthChange
            }
            
            if let lastSoldDate = xmlDoc.root["response"]["results"]["result"]["lastSoldDate"].value {
                property.lastSoldDate = lastSoldDate
            }
            
            if let lastSoldPrice = xmlDoc.root["response"]["results"]["result"]["lastSoldPrice"].value {
                property.lastSoldPrice = lastSoldPrice
            }

            if let localRegionAverage = xmlDoc.root["response"]["results"]["result"]["localRealEstate"]["region"]["zindexValue"].value {
                property.localRegionAverage = localRegionAverage
            }
            
            if let yearBuilt = xmlDoc.root["response"]["results"]["result"]["yearBuilt"].value {
                property.yearBuilt = yearBuilt
            }
            
            if let squareFeet = xmlDoc.root["response"]["results"]["result"]["finishedSqFt"].value {
                property.squareFeet = squareFeet
            }
            
            if let numOfBathrooms = xmlDoc.root["response"]["results"]["result"]["bathrooms"].value {
                property.numOfBathrooms = numOfBathrooms
            }
            
            if let numOfBedrooms = xmlDoc.root["response"]["results"]["result"]["bedrooms"].value {
                property.numOfBedrooms = numOfBedrooms
            }
            
            if let homeDetailsURL = xmlDoc.root["response"]["results"]["result"]["links"]["homedetails"].value {
                property.homeDetailsZillowURL = homeDetailsURL
            }
        }
        catch { print("\(error)") }
    }
    
    static func parseUpdatedPropertyDetails(xmlData: Data?, property: PropertyObject) {
        guard
            let xmlData = xmlData
            else { return }
        
        do {
            let xmlDoc = try AEXMLDocument(xml: xmlData)
            
            if let lotSquareFeet = xmlDoc.root["response"]["editedFacts"]["lotSizeSqFt"].value {
                property.lotSquareFeet = lotSquareFeet
            }
            
            if let useCode = xmlDoc.root["response"]["editedFacts"]["useCode"].value {
                property.type = useCode
            }
            
            if let parkingType = xmlDoc.root["response"]["editedFacts"]["parkingType"].value {
                property.parkingType = parkingType
            }
            
            if let parkingSpaces = xmlDoc.root["response"]["editedFacts"]["coveredParkingSpaces"].value {
                property.parkingSpaces = parkingSpaces
            }
            
            if let houseImageURL = xmlDoc.root["response"]["images"]["image"]["url"].value {
                if let checkedUrl = URL(string: houseImageURL) {
                    property.zillowHomeImageURL = checkedUrl
                }
            }
        }
        catch { print("\(error)") }
    }
}
