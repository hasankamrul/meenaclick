//
//  LocationVC.swift
//  meenaclick
//
//  Created by Md Kamrul Hasan on 15/6/19.
//  Copyright © 2019 Md Kamrul Hasan. All rights reserved.
//

import UIKit

class LocationVC: UIViewController {

    @IBOutlet weak var selectZoneTF: DropDown!
    
    var area : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        sendHader()
        
        // The list of array to display. Can be changed dynamically
        selectZoneTF.optionArray = ["Option 1", "Option 2", "Option 3"]
        //Its Id Values and its optional
        selectZoneTF.optionIds = [1,2,3,4]
        
        // The the Closure returns Selected Index and String
        selectZoneTF.didSelect{(selectedText , index ,id) in
//            self.valueLabel.text = "Selected String: \(selectedText) \n index: \(index)"
        }
        
    }
    
    func sendHader(){
        
        let url = URL(string: "https://meenaclick.com/api/get-all-area")!
        var request = URLRequest(url: url)
//        request.setValue("secret-keyValue", forHTTPHeaderField: "secret-key")
        
        var task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString)")
            
            do {
                
                let allAreaData = try JSONDecoder().decode(locationResponse.self, from: data!)
                print("allAreaData: ",allAreaData)
                DispatchQueue.main.async {
                    allAreaData.data[0].area_name
                    for index in 0..<allAreaData.data.count{
                        self.area.append(allAreaData.data[index].area_name)
                    }
                    self.selectZoneTF.optionArray = self.area
                }
                
                
                
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
        }
        
        task.resume()
    }

}
