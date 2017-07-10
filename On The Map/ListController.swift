//
//  ListController.swift
//  On The Map
//
//  Created by Rishav on 19/04/17.
//  Copyright © 2017 Rishav. All rights reserved.
//

import Foundation
import UIKit

class ListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.fetchLocations()
        }
    }
    
    func fetchLocations() {
        ParseClient.sharedInstance().displayStudentLocations { (locations, success, error) in
            if success {
                DispatchQueue.main.async {
                    self.listTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationOfStudents.Location.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = LocationOfStudents.Location[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentsCell")!
        
        let letters = NSCharacterSet.letters
        let fullName = "\(student.firstName) \(student.lastName)"
        let range = fullName.rangeOfCharacter(from: letters)
        
        if (range != nil) {
            if (student.firstName != nil && student.lastName != nil) {
                cell.textLabel?.text = "\(student.firstName!) \(student.lastName!)"}
            else{
                cell.textLabel?.text = ConstantsParse.NoName
            }
        }
            
        else {
            cell.textLabel?.text = ConstantsParse.NoName
        }
        
        if let mediaUrl = student.mediaURL {
            cell.detailTextLabel?.text = mediaUrl
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let app = UIApplication.shared
        let mediaUrl = LocationOfStudents.Location[indexPath.row].mediaURL
        if let toOpen = mediaUrl {
            if canVerifyUrl(urlString: toOpen) {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            } else {
                showAlert("The URL was not valid and could not be opened")
            }
        }
    }
    
    //Method to show alerts
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Method to verify url
    func canVerifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    @IBAction func logoutAction(_ sender: Any) {
        UdacityClient.sharedInstance().endUserSession { (success, error) in
            if success {
                self.tabBarController?.dismiss(animated: true, completion: nil)
            } else {
                self.showAlert(error!)
            }
            
            
        }
        
    }
}
