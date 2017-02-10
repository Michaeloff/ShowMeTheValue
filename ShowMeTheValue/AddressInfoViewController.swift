//
//  AddressInfoViewController.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/20/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

import UIKit

class AddressInfoViewController: UIViewController {

    @IBOutlet weak var tableViewAddresses: UITableView!
    @IBOutlet weak var textFieldEnteredAddress: UITextField!
    @IBOutlet weak var buttonFind: UIButton!
    @IBOutlet weak var buttonRefresh: UIButton!
    @IBOutlet weak var segControlSearchRadius: UISegmentedControl!
    
    let textCellIdentifier = "TextCell"
    var addressItems: [String] = []
    var addressNum = 0
    var errorLoading = false
    var propertyToEstimate = PropertyObject()
    let feet25 =  0.000069
    let feet50 =  0.000137
    let feet100 = 0.000274
    let feet200 = 0.000548
    var searchRadius = 0.0
    var rotateSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonRefresh.isEnabled = false
        setSearchRadius()
        self.initTextField()
        self.initTable()
        self.getAddressesNearMe()
    }

    func setSearchRadius() {
        switch segControlSearchRadius.selectedSegmentIndex {
        case 0: searchRadius = feet25
        case 1: searchRadius = feet50
        case 2: searchRadius = feet100
        case 3: searchRadius = feet200
        default: searchRadius = feet50
        }
    }
    
    func getAddressesNearMe() {
        guard
            LocationManager.sharedInstance.locationCheckingAuthorized,
            let currentLocation = LocationManager.sharedInstance.locationManager.location
            else { return }
        
        JsonManager.locationItems.removeAll()
        addressItems.removeAll()
        self.addressNum = 0
        lookupAddressByLatitudeLongitude(lat:currentLocation.coordinate.latitude, long:currentLocation.coordinate.longitude)
    }
    
    func lookupAddressByLatitudeLongitude(lat: Double, long:Double)  {
        JsonManager.lookupAddressByLatLong(latitude: lat, longitude: long, onCompletion: self.displayResults)
    }
    
    func displayResults(errorText: String) {
        if errorText != "" {
            let alertTitle = "Error Getting Addresses"
            let alertMessage = "\nUnable to look up addresses due to the following: " + errorText
            displayAlert(title: alertTitle, message: alertMessage)
            errorLoading = true
            updateTable()
            return
        }
        
        guard let currentLocation = LocationManager.sharedInstance.locationManager.location else { return }
        
        for locationItem in JsonManager.locationItems {
            // Could use a "Set<String>()" instead of an array, but the order and ability to subscript are needed
            if !addressItems.contains(locationItem.addressToQuery) {
                addressItems.append(locationItem.addressToQuery)
            }
        }
        self.addressNum += 1
        if addressNum < 5 {
            let lat = currentLocation.coordinate.latitude
            let long = currentLocation.coordinate.longitude
            let searchRadiusRotate = rotateSearch ? searchRadius : 0.0
            
            switch addressNum {
            case 1: lookupAddressByLatitudeLongitude(lat:lat + searchRadius, long:long + searchRadiusRotate)  //  x,  x   OR    x,  0
            case 2: lookupAddressByLatitudeLongitude(lat:lat - searchRadius, long:long - searchRadiusRotate)  // -x, -x   OR   -x,  0
            case 3: lookupAddressByLatitudeLongitude(lat:lat - searchRadiusRotate, long:long + searchRadius)  // -x,  x   OR    0,  x
            case 4: lookupAddressByLatitudeLongitude(lat:lat + searchRadiusRotate, long:long - searchRadius)  //  x, -x   OR    0, -x
            default: ()
            }
        }
        updateTable()
    }
    
    func updateTable() {
        DispatchQueue.main.async{
            self.tableViewAddresses.reloadData()
            if self.addressNum == 5 {
                self.buttonRefresh.isEnabled = true
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        DispatchQueue.main.async{
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func refreshButtonTouched(_ sender: Any) {
        self.buttonRefresh.isEnabled = false
        errorLoading = false
        rotateSearch = !rotateSearch
        LocationManager.sharedInstance.locationManager.startUpdatingLocation()
        self.getAddressesNearMe()
    }
    
    @IBAction func segControlTouched(_ sender: UISegmentedControl) {
        setSearchRadius()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        self.propertyToEstimate.reset()
        
        if identifier == "ShowEstimateFromFindButtonSegue" {
            if let enteredAddress = textFieldEnteredAddress.text,
                Utilities.confirmValidAddress(address: enteredAddress, property: self.propertyToEstimate) {
                return true
            }
        }
        else if identifier == "ShowEstimateFromTableSegue" {
            if addressItems.count <= 0 { return false }
            
            if let addressIndex = tableViewAddresses.indexPathForSelectedRow?.row,
                Utilities.confirmValidAddress(address: addressItems[addressIndex], property: self.propertyToEstimate) {
                return true
            }
        }
        let alertTitle = "Address Format Issue"
        let alertMessage = "\nPlease type the address separated by commas either as: 'street, zip' or 'street, city, state'\nFor example:\n2114 Bigelow Ave, 98109\n2114 Bigelow Ave, Seattle, WA"
        displayAlert(title: alertTitle, message: alertMessage)
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddressEstimateViewController {
            destination.property = self.propertyToEstimate
        }
    }
}

// Extension for textfield-related methods. Used for code cleanliness.
extension AddressInfoViewController: UITextFieldDelegate {
    
    func initTextField() {
        textFieldEnteredAddress.delegate = self
        textFieldEnteredAddress.layer.borderWidth = 1.0
        textFieldEnteredAddress.layer.borderColor = UIColor.lightGray.cgColor
        hideKeyboardWhenTappedAround()
    }
    
    // Called when 'return' key pressed. Return false to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        buttonFind.sendActions(for: .touchUpInside)
        textField.resignFirstResponder()
        return true
    }
    
    func hideKeyboardWhenTappedAround() {
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddressInfoViewController.dismissKeyboard))
        // Uncomment the line below if you want the tap to not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Calls this function when the tap is recognized.
    func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}


// Extension for table-related methods. Used for code cleanliness.
extension AddressInfoViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func initTable() {
        tableViewAddresses.delegate = self
        tableViewAddresses.dataSource = self
        tableViewAddresses.layer.borderWidth = 1.0
        tableViewAddresses.layer.borderColor = UIColor.lightGray.cgColor
        tableViewAddresses.contentInset = UIEdgeInsetsMake(-60, 0, 0, 0)
    }
    
    // Table methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if addressItems.count == 0 {
            return 1 // Loads dummy cell notifying user that addresses are loading.
        }
        else {
            return addressItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewAddresses.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        if addressItems.count > 0 {
            cell.textLabel?.text = addressItems[indexPath.row]
        }
        else {
            if errorLoading {
                cell.textLabel?.text = ""
            }
            else if LocationManager.sharedInstance.locationCheckingAuthorized {
                cell.textLabel?.text = "Finding Addresses..."
            }
            else {
                cell.textLabel?.text = "Set location access to find addresses."
            }
        }
        return cell
    }
}





