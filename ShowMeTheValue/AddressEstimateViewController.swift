//
//  AddressEstimateViewController.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/21/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

import UIKit

class AddressEstimateViewController: UIViewController {
    
    @IBOutlet weak var labelPropertyAddress: UILabel!
    @IBOutlet weak var labelZEstimate: UILabel!
    @IBOutlet weak var buttonWhatsAZestimate: UIButton!
    @IBOutlet weak var label30DayChange: UILabel!
    @IBOutlet weak var label30DayChangeValue: UILabel!
    @IBOutlet weak var labelLastSoldChange: UILabel!
    @IBOutlet weak var labelLastSoldChangeValue: UILabel!
    @IBOutlet weak var labelLastSoldPriceAndDate: UILabel!
    @IBOutlet weak var labelLastSoldPriceAndDateValue: UILabel!
    @IBOutlet weak var labelLocalRegionAverage: UILabel!
    @IBOutlet weak var labelLocalRegionAverageValue: UILabel!
    @IBOutlet weak var buttonMoreDetails: UIButton!
    @IBOutlet weak var labelNoZillowImageFound: UILabel!
    @IBOutlet weak var imageViewProperty: UIImageView!
    @IBOutlet weak var constraintFromZestimateToWhatsAZestimate: NSLayoutConstraint!
    
    var property = PropertyObject()
    let darkGreen = UIColor(red: 0, green: 170/255, blue: 0, alpha: 1)
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if Utilities.iPhoneWidth4or5() {
            constraintFromZestimateToWhatsAZestimate.constant = 5
            labelZEstimate.font = labelZEstimate.font.withSize(16)
            label30DayChange.font = label30DayChange.font.withSize(16)
            label30DayChangeValue.font = label30DayChangeValue.font.withSize(16)
            labelLastSoldChange.font = labelLastSoldChange.font.withSize(16)
            labelLastSoldChangeValue.font = labelLastSoldChangeValue.font.withSize(16)
            labelLastSoldPriceAndDate.font = labelLastSoldPriceAndDate.font.withSize(16)
            labelLastSoldPriceAndDateValue.font = labelLastSoldPriceAndDateValue.font.withSize(16)
            labelLocalRegionAverage.font = labelLocalRegionAverage.font.withSize(16)
            labelLocalRegionAverageValue.font = labelLocalRegionAverageValue.font.withSize(16)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageViewProperty.contentMode = .scaleAspectFit
        labelPropertyAddress.text = property.displayableAddress
        XmlManager.getDeepSearchResults(property: property, onCompletion: self.parseDeepSearchResults)
    }
    
    func parseDeepSearchResults(xmlData: Data?) {
        XmlManager.parseDeepSearchResults(xmlData: xmlData, property: property)
        if self.property.errorCode != "0" {
            self.addressNotFound()
            return
        }
        DispatchQueue.main.async() { () -> Void in
            self.label30DayChange.isHidden = false
            self.label30DayChangeValue.isHidden = false
            self.labelLastSoldChange.isHidden = false
            self.labelLastSoldChangeValue.isHidden = false
            self.labelLastSoldPriceAndDate.isHidden = false
            self.labelLastSoldPriceAndDateValue.isHidden = false
            self.buttonMoreDetails.isHidden = false
            
            self.labelZEstimate.text = "Zestimate®: $" + Utilities.formatNumWithCommas(self.property.estimate)
            if self.property.oneMonthChange.contains("-") {
                self.label30DayChangeValue.text = "-$" + Utilities.formatNumWithCommas(self.property.oneMonthChange)
                self.label30DayChangeValue.textColor = UIColor.red
            }
            else {
                self.label30DayChangeValue.text = "+$" + Utilities.formatNumWithCommas(self.property.oneMonthChange)
                self.label30DayChangeValue.textColor = self.darkGreen
            }
            
            // last sold change
            if let zestimateInt = Int(self.property.estimate), let lastSoldPriceInt = Int(self.property.lastSoldPrice) {
                let lastSoldChange = zestimateInt - lastSoldPriceInt
                if lastSoldChange < 0 {
                    self.labelLastSoldChangeValue.text = "-$" + Utilities.formatNumWithCommas(lastSoldChange)
                    self.labelLastSoldChangeValue.textColor = UIColor.red
                }
                else {
                    self.labelLastSoldChangeValue.text = "+$" + Utilities.formatNumWithCommas(lastSoldChange)
                    self.labelLastSoldChangeValue.textColor = self.darkGreen
                }
            }
            
            self.labelLastSoldPriceAndDate.text = "Last sold price (" + self.property.lastSoldDate + "):"
            self.labelLastSoldPriceAndDateValue.text = "$" + Utilities.formatNumWithCommas(self.property.lastSoldPrice)
            if self.property.localRegionAverage != "" {
                self.labelLocalRegionAverage.isHidden = false
                self.labelLocalRegionAverageValue.isHidden = false
                self.labelLocalRegionAverageValue.text = "$" + Utilities.formatNumWithCommas(self.property.localRegionAverage)
            }
        }
        
        XmlManager.getUpdatedPropertyDetails(zpid: property.zpid, onCompletion: parseUpdatedPropertyDetails)
    }
    
    func addressNotFound() {
        DispatchQueue.main.async() { () -> Void in
            self.labelPropertyAddress.isHidden = true
            self.labelZEstimate.isHidden = true
            self.buttonWhatsAZestimate.isHidden = true
            
            let title = "No exact match was found for the address:\n" + self.property.displayableAddress
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left
            let messageText = NSMutableAttributedString(
                string: "\nPossible reasons include:\n\n- An address range or missing street number refers to multiple addresses, and a single address is required.\n\n- Commercial, newer or private properties may not be in the database.\n\n- The spelling of the address may be incorrect if entered manually.",
                attributes: [
                    NSParagraphStyleAttributeName: paragraphStyle,
                    NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
                ])
            
            let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) -> Void in
                _ = self.navigationController?.popViewController(animated: true)
            }))
            alertController.setValue(messageText, forKey: "attributedMessage")
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func parseUpdatedPropertyDetails(xmlData: Data?) {
        XmlManager.parseUpdatedPropertyDetails(xmlData: xmlData, property: property)
        
        DispatchQueue.main.async() { () -> Void in
            if let zillowHomeImageURL = self.property.zillowHomeImageURL {
                ImageHelper.downloadImage(url: zillowHomeImageURL, imageView: self.imageViewProperty)
            }
            else {
                JsonManager.getStreetViewMetaData(latitude: self.property.latitude, longitude: self.property.longitude, onCompletion: self.downloadStreetViewImage)
            }
        }
    }
    
    func downloadStreetViewImage(imageURL: String) {
        if let checkedUrlStreetView = URL(string: imageURL) {
            self.labelNoZillowImageFound.isHidden = false
            self.property.googleStreetViewImageURL = checkedUrlStreetView
            ImageHelper.downloadImage(url: checkedUrlStreetView, imageView: self.imageViewProperty)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "ShowDetailsSegue",
            let destination = segue.destination as? AddressDetailsViewController {
            destination.property = self.property
        }
    }
    
    // What's a Zestimate? http://www.zillow.com/zestimate/
    @IBAction func ZillowZestimateExplanationWebpage(_ sender: UIButton) {
        if let url = NSURL(string: "http://www.zillow.com/zestimate/"){
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

