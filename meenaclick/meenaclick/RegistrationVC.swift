//
//  RegistrationVC.swift
//  meenaclick
//
//  Created by Md Kamrul Hasan on 15/6/19.
//  Copyright © 2019 Md Kamrul Hasan. All rights reserved.
//

import UIKit

class RegistrationVC: UIViewController {
    

    @IBOutlet weak var mobileNoTF: AkiraTextField!
    @IBOutlet weak var pinCodeTF: AkiraTextField!
    @IBOutlet weak var fullNameTF: AkiraTextField!
    @IBOutlet weak var emailTF: AkiraTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func signUpBtn(_ sender: Any) {
        if let mobileNo = mobileNoTF.text, let pinCode = pinCodeTF.text, let fullName = fullNameTF.text, let email = emailTF.text{
            
            var parameter = [
                "mobile": mobileNo,
                "email": email,
                "full_name": fullName,
                "pin_code": pinCode
            ]
            postAction(url: "https://www.meenaclick.com/api/v2/registration-try", parameters: parameter, api: "registration-try")
            
        }
    }
    
    func postAction(url: String, parameters: [String: Any],api: String){
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters = parameters
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
            do {
                
                let registrationResponseData = try JSONDecoder().decode(registrationResponse.self, from: data)
                print("registrationResponseData: ",registrationResponseData)
                
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
        }
        
        task.resume()
    }

}







