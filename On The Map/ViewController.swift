//
//  ViewController.swift
//  On The Map
//
//  Created by Rishav on 19/04/17.
//  Copyright © 2017 Rishav. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passKeyTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTextField.delegate = self
        passKeyTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    @IBAction func login(_ sender: Any) {
        self.view.endEditing(true)
        UdacityClient.sharedInstance().authenticateUser(username: userTextField.text!, password: passKeyTextField.text!) { (result, error) in
            if error != nil {
                self.showError(error!)
            } else {
                DispatchQueue.main.async {
                    self.Login()
                }
            }
        }
    }
    
    @IBAction func signupAction(_ sender: Any) {
        UIApplication.shared.open(URL(string: ConstantsUdacity.SignUpUrl)!, options: [:], completionHandler: nil)
    }
    
    func Login() {
        userTextField.text = ""
        passKeyTextField.text = ""
        if let mapAndTableController = storyboard?.instantiateViewController(withIdentifier: "MapAndTableController") {
            present(mapAndTableController, animated: true, completion: nil)
        }
        
    }
    
    func showActivitySpinner(_ spinner: UIActivityIndicatorView!, style: UIActivityIndicatorViewStyle) {
        DispatchQueue.main.async {
            let activitySpinner = spinner
            activitySpinner?.activityIndicatorViewStyle = style
            activitySpinner?.hidesWhenStopped = true
            activitySpinner?.isHidden = false
            activitySpinner?.startAnimating()
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
        let Error = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
        Error.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(Error, animated: true, completion: nil)
    }
    
    func canVerifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
}

