//
//  LoginViewController.swift
//  ice_warp
//
//  Created by Anjali Pandey on 07/12/24.
//

import UIKit
import SwiftyJSON
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var textField_Email: UITextField!
    
    @IBOutlet weak var textField_Password: UITextField!
    
    @IBOutlet weak var textField_Host: UITextField!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var persistentContainer: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            persistentContainer = appDelegate.persistentContainer.viewContext
        }
        
        hideLoader()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if PrefManager.shared.getAuthorizationToken() != nil {
                self.performSegue(withIdentifier: "openChannel", sender: self)
                return
            }
        }

    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }
    
    // MARK: - Actions
    
    @IBAction func authenticateUser(_ sender: UIButton) {
        
        guard let email = textField_Email.text, !email.isEmpty else {
            
            let alert = UIAlertController(title: "Error", message: "Please enter email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alert, animated: true)
            
            return
            
        }
        
        guard let password = textField_Password.text, !password.isEmpty else {
            
            let alert = UIAlertController(title: "Error", message: "Please enter password", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alert, animated: true)
            
            return
        }
  
        guard let host = textField_Host.text, !host.isEmpty else {
            
            let alert = UIAlertController(title: "Error", message: "Please enter host", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alert, animated: true)
            
            return
            
        }
        
        self.showLoader()
        
        loginToIceWarp(
            username: email,
            password: password
        ) { result in
                
            self.hideLoader()
            
            switch result {
                
            case .success(let data):
                self.processLoginResponse(data)
                
            case .failure(let error):
                print("===========> Error: \(error)")
            }
            
        }
            
                    
    }
    
    private func showLoader() {
        loader.isHidden = false
        loader.startAnimating()
    }
    
    private func hideLoader() {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.loader.stopAnimating()
        }
    }
    
    private func processLoginResponse(_ response: Data) {
        
        if let responseString = String(data: response, encoding: .utf8) {
                print("Login successful: \(responseString)")
            
            if let jsonData = responseString.data(using: .utf8) {
                do {
                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: jsonData)
                    print("Authorized: \(authResponse.authorized)")
                    print("Token: \(authResponse.token)")
                    print("Host: \(authResponse.host)")
                    print("Email: \(authResponse.email)")
                    print("OK: \(authResponse.ok)")
                    
                    // Save to core data
                    saveAccountToCoreData(authResponse, context: persistentContainer)
                    
                    // Save to token in pre manager / user default
                    PrefManager.shared.setAuthorizationToken(authResponse.token)
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "openChannel", sender: self)
                    }
                    
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            }
            
        }
        
    }

    private func loginToIceWarp(
        username: String,
        password: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        
        let urlString = "https://mofa.onice.io/teamchatapi/iwauthentication.login.plain"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let parameters: [String: String] = [
            "username": username,
            "password": password
        ]
    
        let parameterString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        guard let postData = parameterString.data(using: .utf8) else {
            completion(.failure(NSError(domain: "Encoding Error", code: 0, userInfo: nil)))
            return
        }
        
    
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        // Create a URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(.success(data))
                } else {
                    let error = NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"
                    ])
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    

}
