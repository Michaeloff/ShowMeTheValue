//
//  AddressDetailsViewController.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/24/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

import UIKit

class AddressDetailsViewController: UIViewController {
    
    @IBOutlet weak var labelPropertyAddress: UILabel!
    @IBOutlet weak var labelYearBuilt: UILabel!
    @IBOutlet weak var labelSquareFeet: UILabel!
    @IBOutlet weak var labelLotSquareFeet: UILabel!
    @IBOutlet weak var labelNumOfBathrooms: UILabel!
    @IBOutlet weak var labelNumOfBedrooms: UILabel!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelParking: UILabel!
    @IBOutlet weak var labelUsingStreetViewImage: UILabel!
    @IBOutlet weak var imageViewProperty: UIImageView!
    
    var address = ""
    var property = PropertyObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageViewProperty.contentMode = .scaleAspectFit
        populateLabels()
    }
    
    func populateLabels() {
        labelPropertyAddress.text = address
        labelYearBuilt.text = property.yearBuilt
        labelSquareFeet.text = Utilities.formatNumWithCommas(property.squareFeet)
        labelLotSquareFeet.text = Utilities.formatNumWithCommas(property.lotSquareFeet)
        labelNumOfBathrooms.text = property.numOfBathrooms
        labelNumOfBedrooms.text = property.numOfBedrooms
        labelType.text = property.type
        labelParking.text = getParkingText()
        
        if let googleStreetViewImageURL = self.property.googleStreetViewImageURL {
            labelUsingStreetViewImage.isHidden = false
            ImageHelper.downloadImage(url: googleStreetViewImageURL, imageView: self.imageViewProperty)
        }
        else {
            JsonManager.getStreetViewMetaData(latitude: self.property.latitude, longitude: self.property.longitude, onCompletion: self.downloadStreetViewImage)
        }
    }

    func downloadStreetViewImage(imageURL: String) {
        if let checkedUrlStreetView = URL(string: imageURL) {
            labelUsingStreetViewImage.isHidden = false
            self.property.googleStreetViewImageURL = checkedUrlStreetView
            ImageHelper.downloadImage(url: checkedUrlStreetView, imageView: self.imageViewProperty)
        }
        else if let zillowHomeImageURL = self.property.zillowHomeImageURL {
            ImageHelper.downloadImage(url: zillowHomeImageURL, imageView: self.imageViewProperty)
        }
    }
    
    func getParkingText() -> String {
        var parkingText = property.parkingType
        if let indexOfComma = parkingText.range(of: ",")?.lowerBound {
            parkingText = parkingText.substring(to: indexOfComma)
        }
        if property.parkingSpaces != "" {
            parkingText += ", \(property.parkingSpaces) spaces"
        }
        return parkingText
    }
    
    @IBAction func homeDetailsOnZillow(_ sender: UIButton) {
        if let url = NSURL(string: property.homeDetailsZillowURL) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    // Provided by Zillow
    //http://www.zillow.com/widgets/GetVersionedResource.htm?path=/static/logos/Zillowlogo_200x50.gif
    @IBAction func ZillowHomeWebpage(_ sender: UIButton) {
        // Launches Safari with Zillow home page, or launches the Zillow app if installed
        if let url = NSURL(string: "http://www.zillow.com/"){
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    // © Zillow, Inc., 2006-2017. Use is subject to Terms of Use http://www.zillow.com/corp/Terms.htm
    @IBAction func ZillowTermsOfUse(_ sender: UIButton) {
        if let url = NSURL(string: "http://www.zillow.com/corp/Terms.htm"){
            UIApplication.shared.openURL(url as URL)
        }
    }
}
