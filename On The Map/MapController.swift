//
//  MapController.swift
//  On The Map
//
//  Created by Rishav on 19/04/17.
//  Copyright © 2017 Rishav. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [MKPointAnnotation]()
    
    
    func populateMap() {
        ParseClient.sharedInstance().displayStudentLocations() { (locations, success, error) in
            if success {
                for location in locations! {
                    if let lat = location.latitude, let long = location.longitude,
                        let fName = location.firstName, let lName = location.lastName,
                        let mediaURL =  location.mediaURL {
                        let annotation = MKPointAnnotation()
                        let lattDegrees = CLLocationDegrees(lat)
                        let longDegrees = CLLocationDegrees(long)
                        let coordinate = CLLocationCoordinate2D(latitude: lattDegrees, longitude: longDegrees)
                        annotation.coordinate = coordinate
                        annotation.title = "\(fName) \(lName)"
                        if mediaURL.isEmpty {
                            annotation.subtitle = ConstantsParse.DefaultURL
                        } else {
                            annotation.subtitle = mediaURL
                        }
                        self.annotations.append(annotation)
                    }
                    
                }
                DispatchQueue.main.async {
                    self.mapView.removeAnnotations(self.annotations)
                    self.mapView.addAnnotations(self.annotations)
                }
            }
            else {
                self.showError(error!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.addAnnotations(annotations)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        DispatchQueue.main.async {
            self.populateMap()
        }
    }

    
    @IBAction func logoutAction(_ sender: Any) {
        UdacityClient.sharedInstance().endUserSession { (success, error) in
            if success {
                self.tabBarController?.dismiss(animated: true, completion: nil)
            } else {
                self.showError(error!)
            }
        }
    }
    
    func showError(_ error: String) {
        let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func canVerifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "reuse"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle {
                if canVerifyUrl(urlString: toOpen) {
                    app.open(URL(string: toOpen!)!, options: [:], completionHandler: nil)
                } else {
                    showError("URL not valid and could not be opened")
                }
            }
        }
    }
}
