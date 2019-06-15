//
//  ViewController.swift
//  meenaclick
//
//  Created by Md Kamrul Hasan on 15/6/19.
//  Copyright © 2019 Md Kamrul Hasan. All rights reserved.
//

import UIKit

//    Login Check
struct loginCheckResponse: Decodable {
    var validation: String
    var login_data: loginData?
}
struct loginData: Decodable {
    var mobile: String
    var account_exists: Bool
    var customer: CustomerData?
}

//    registration
struct registrationResponse: Decodable {
    var status: String
    var customerData: CustomerData?
    var validation: Bool?
    var message: String?
}

//    Process Login
struct processLoginResponse: Decodable {
    var status: String
    var message: String
    var customerData: CustomerData?
}

struct CustomerData: Decodable {
    var id: Int
    var customer_name: String
    var email: String
    var mobile: String
}



//    location
struct locationResponse: Decodable {
    var ack: Bool
    var data: [Area]
}
struct Area: Decodable {
    var id: Int
    var outlet_id: String?
    var area_name: String
    var area_status: String?
}

class ViewController: UIViewController {
    
////    Login Check
//    struct loginCheckResponse: Decodable {
//        var validation: String
//        var login_data: loginData
//    }
//    struct loginData: Decodable {
//        var mobile: String
//        var account_exists: Bool
//        var customer: CustomerData?
//    }
//
//    //    registration
//    struct registrationResponse: Decodable {
//        var status: String
//        var customerData: CustomerData?
//        var validation: Bool?
//        var message: String?
//    }
//
////    Process Login
//    struct processLoginResponse: Decodable {
//        var status: String
//        var message: String
//        var customerData: CustomerData?
//    }
//
//    struct CustomerData: Decodable {
//        var id: Int
//        var customer_name: String
//        var email: String
//        var mobile: String
//    }
//
//
//
////    location
//    struct locationResponse: Decodable {
//        var ack: Bool
//        var data: [Area]
//    }
//    struct Area: Decodable {
//        var id: Int
//        var outlet_id: String?
//        var area_name: String
//        var area_status: String?
//    }
    
    @IBOutlet weak var mobileNoTF: AkiraTextField!
    @IBOutlet weak var pinCodeTF: AkiraTextField!
    
    var accountStatus = true
    var flag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinCodeTF.isHidden = true
        
    }
    
    @IBAction func verifyBtn(_ sender: Any) {
        if flag == true{
            if let mobileNo = mobileNoTF.text,let pinCode = pinCodeTF.text{
             var parameter = ["mobile_no" : mobileNo,
                              "check_pin_code": pinCode]
                postAction(url: "https://meenaclick.com/api/v2/process-login", parameters: parameter, api: "process-login")
                
            }
        }
        
        if let mobileNo = mobileNoTF.text{
            
            var parameter = ["mobile_no" : mobileNo]
            postAction(url: "https://meenaclick.com/api/v2/login-check", parameters: parameter, api: "login-check")
            
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
                if api == "process-login"{
                    let processLoginResponseData = try JSONDecoder().decode(processLoginResponse.self, from: data)
                    print("processLoginResponseData: ",processLoginResponseData)
                    
                    var status = processLoginResponseData.status
                    DispatchQueue.main.async {
                        if status == "success"{
                            self.performSegue(withIdentifier: "locationSegue", sender: self)
                        }
                    }
                    return
                }
                
                let loginCheckResponseData = try JSONDecoder().decode(loginCheckResponse.self, from: data)
                print("loginCheckResponseData: ",loginCheckResponseData)
                
                self.accountStatus = loginCheckResponseData.login_data!.account_exists
                
                DispatchQueue.main.async {
                    if self.accountStatus == false{
                        self.performSegue(withIdentifier: "registrationSegue", sender: nil)
                    }else{
                        self.pinCodeTF.isHidden = false
                        self.flag = true
                    }
                }
                
                
                
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
        }
        
        task.resume()
    }


}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

