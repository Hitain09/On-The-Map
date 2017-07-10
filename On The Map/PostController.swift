//
//  PostController.swift
//  On The Map
//
//  Created by Rishav on 19/04/17.
//  Copyright © 2017 Rishav. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PostController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    
    enum ViewOnDisplay {
        case FormView
        case MapView
        case LinkView
    }
    struct Location {
        let latitude: Double
        let longitude: Double
        let mapString: String
        var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
    }
    
    var posterLatitude: CLLocationDegrees? = nil
    var posterLongitude: CLLocationDegrees? = nil
    
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var formLabel: UILabel!
    @IBOutlet weak var formText: UITextField!
    @IBOutlet weak var formSearch: UIButton!
    @IBOutlet weak var formSpinner: UIActivityIndicatorView!
    
    
    @IBOutlet weak var mapWrappedView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewButton: UIButton!
    
    @IBOutlet weak var webView: UIView!
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var webTextField: UITextField!
    @IBOutlet weak var webLabel: UILabel!
    
    @IBAction func searchAction(_ sender: Any) {
        
        self.view.endEditing(true)
        showActivitySpinner(self.formSpinner, style: .gray)
        
        let geocoder = CLGeocoder()
        
        guard let place = formText.text else {
            self.showError("Enter a location")
            return
        }
        
        geocoder.geocodeAddressString(place) { (placemarks, error) in
            
            if error != nil {
                self.showError("Error! Location not found")
                self.hideActivitySpinner(self.formSpinner)
            } else {
                self.displayView(.MapView)
                
                let placemark = placemarks?.first
                
                if let placemark = placemark {
                    let coordinate = placemark.location?.coordinate
                    
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: coordinate!, span: span)
                    
                    let annotation = MKPointAnnotation()
                    
                    annotation.coordinate = coordinate!
                    
                    self.posterLatitude = coordinate?.latitude
                    self.posterLongitude = coordinate?.longitude
                    
                    DispatchQueue.main.async {
                        self.mapView.removeAnnotation(annotation)
                        self.mapView.addAnnotation(annotation)
                        self.mapView.setRegion(region, animated: true)
                        self.hideActivitySpinner(self.formSpinner)
                    }
                    
                } else {
                    self.showError("No match found")
                }
            }
            
            
        }
        
    }
    @IBAction func placePinAction(_ sender: Any) {
        self.displayView(.LinkView)
    }
    @IBAction func websiteSubmitAction(_ sender: Any) {
        
        if webTextField.text!.isEmpty {
            displayAlert("No Website", errorMsg: "Please add an existing website")
            return
        }
        
        ParseClient.sharedInstance().postStudentLocation(mapString: formText.text!, mediaUrl: webTextField.text!, latitude: posterLatitude!, longitude: posterLongitude!) { (result, success, error) in
            if error != nil{
                DispatchQueue.main.async {
                    self.displayAlert("Network Problem!", errorMsg: "Please check your internet connection")
                }
                return
            }
            else{
                _=result
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.hideActivitySpinner(self.formSpinner)
            }
        }
    }
    func displayAlert(_ errorTitle: String, errorMsg: String) {
        
        let alert = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelSearchLocation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelMapLocation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelWebsiteLocation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func showActivitySpinner(_ spinner: UIActivityIndicatorView!, style: UIActivityIndicatorViewStyle) {
        DispatchQueue.main.async {
            let activitySpinner = spinner
            activitySpinner?.activityIndicatorViewStyle = style
            activitySpinner?.hidesWhenStopped = true
            activitySpinner?.isHidden = false
            activitySpinner?.startAnimating()
            if let spinner = activitySpinner {
                self.view.addSubview(spinner)
            }
        }
    }
    func hideActivitySpinner(_ spinner: UIActivityIndicatorView!) {
        DispatchQueue.main.async {
            let activitySpinner = spinner
            activitySpinner?.isHidden = true
            activitySpinner?.stopAnimating()
        }
    }
    
     func showError(_ error: String) {
        let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func canVerifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    func displayView(_ viewToDisplay: ViewOnDisplay) {
        switch viewToDisplay {
        case .FormView:
            formView.isHidden = false
            mapWrappedView.isHidden = true
            webView.isHidden = true
        case .MapView:
            formView.isHidden = true
            mapWrappedView.isHidden = false
            webView.isHidden = true
        case .LinkView:
            formView.isHidden = true
            mapWrappedView.isHidden = true
            webView.isHidden = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        formSpinner.isHidden = true
        self.displayView(.FormView)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
