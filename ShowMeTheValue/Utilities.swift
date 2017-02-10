//
//  Utilities.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/25/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

import UIKit

struct Utilities {
    
    static func formatNumWithCommas(_ numberToFormat: String) -> String {
        guard let numberToFormatInt = Int(numberToFormat) else { return numberToFormat }
        
        return formatNumWithCommas(numberToFormatInt)
    }
    
    static func formatNumWithCommas(_ numberToFormat: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        if let formattedNumber = numberFormatter.string(from: NSNumber(value: numberToFormat)) {
            return formattedNumber
        }
        return String(numberToFormat)
    }
    
    // iPhone 4s               screen height = 480 (320 width, 1.5 ratio) - not supported
    // iPhone 5/5s             screen height = 568 (320 width, 1.77 ratio, 16:9)
    // iPhone 6/6s             screen height = 667 (375 width, 1.77 ratio, 16:9)
    // iPhone 6/6s Plus        screen height = 736 (414 width, 1.77 ratio, 16:9)
    // iPad 2, iPad Air/Air 2  screen height = 768 (1024 width, 1.33 ratio)
    // iPad Pro                screen height = 1366 (1024 width, 1.33 ratio)
    static func iPhoneWidth4or5() -> Bool {
        if UIScreen.main.bounds.size.width <= 320 {
            return true
        }
        return false
    }
    
    static func confirmValidAddress(address: String, property: PropertyObject) -> Bool {
        var splitAddress = address.components(separatedBy: ",")

        if splitAddress.count == 2 {
            property.street = splitAddress[0]
            property.zip = splitAddress[1].trimmingCharacters(in: .whitespaces)
            // U.S. zips can be five numbers '12345' or five nums, a dash, and 1-4 nums. '12345-6789'. Just do basic check of leading 5 digits.
            let zip = property.zip
            if zip.characters.count >= 5
            {
                let firstFiveZip = zip[zip.startIndex ... zip.index(zip.startIndex, offsetBy: 4)]
                if let _ = Int(firstFiveZip) {
                    property.displayableAddress = property.street + ", " + property.zip
                    return true
                }
            }
        }
        else if splitAddress.count == 3 {
            property.street = splitAddress[0]
            property.city = splitAddress[1].trimmingCharacters(in: .whitespaces)
            property.state = splitAddress[2].trimmingCharacters(in: .whitespaces)
            property.displayableAddress = property.street + ", " + property.city + ", " + property.state
            return true
        }
        
        return false
    }
        
    // Limitations: Requires names to have the 1st letter capitalized, and the two-letter state name caps
    // Using the String.capitalized method causes a problem in that all non-first letters are lower-cased. This creates
    // a problem for the state name. E.g. CA becomes Ca, which is not accepted by the detector.
    // Usage: 
    //      let results = Utilities.getPostalAddressFromString(addressString: address)
    //          for result in results {
    //              let street = result[NSTextCheckingStreetKey] ?? ""
    //              let city = result[NSTextCheckingCityKey] ?? ""
    //              let state = result[NSTextCheckingStateKey] ?? ""
    //              let zip = result[NSTextCheckingZIPKey] ?? "" }
    static func getPostalAddressFromString(addressString: String) -> [[String: String]] {
        var resultsArray =  [[String: String]]()
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue)
            let matches = detector.matches(in: addressString, options: [], range: NSRange(location: 0, length: addressString.utf16.count))
        
            // Put matches into array of Strings
            for match in matches {
                if match.resultType == .address,
                    let components = match.addressComponents {
                    resultsArray.append(components)
                } else {
                    print("no components found")
                }
            }
        }
        catch { print("\(error)") }
        
        return resultsArray
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
