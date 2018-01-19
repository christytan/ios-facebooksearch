//
//  ViewController.swift
//  christyiosfirst
//
//  Created by chen tan on 4/10/17.
//  Copyright © 2017 chen tan. All rights reserved.
//

import UIKit
import Alamofire
import EasyToast
import SwiftyJSON


class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var ClearBtn: UIButton!
    
    @IBOutlet weak var btnMenuBack: UIBarButtonItem!

    @IBOutlet weak var keyword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if revealViewController() != nil {
            btnMenuBack.target = revealViewController()
            btnMenuBack.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
//                var IdArray = UserDefaults.standard.value(forKey: "appendidArray") as! [String]
//                IdArray.removeAll()
//                UserDefaults.standard.set(IdArray, forKey: "appendidArray")
//        
//                var ImgArray = UserDefaults.standard.value(forKey: "appendidArray") as! [String]
//                ImgArray.removeAll()
//                UserDefaults.standard.set(ImgArray, forKey: "appendimgArray")
//        
//                var NameArray = UserDefaults.standard.value(forKey: "appendidArray") as! [String]
//                NameArray.removeAll()
//                UserDefaults.standard.set(NameArray, forKey: "appendnameArray")
//                
//                UserDefaults.standard.synchronize()
        
//                        var IdArray = UserDefaults.standard.value(forKey: "pageappendidArray") as! [String]
//                        IdArray.removeAll()
//                        UserDefaults.standard.set(IdArray, forKey: "pageappendidArray")
        
//                        var ImgArray = UserDefaults.standard.value(forKey: "pageappendidArray") as! [String]
//                        ImgArray.removeAll()
//                        UserDefaults.standard.set(ImgArray, forKey: "pageappendimgArray")
//        
//                        var NameArray = UserDefaults.standard.value(forKey: "pageappendidArray") as! [String]
//                        NameArray.removeAll()
//                        UserDefaults.standard.set(NameArray, forKey: "pageappendnameArray")
//                        
//                        UserDefaults.standard.synchronize()

        
      
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //perform toast when keyboard is empty
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "searchbtn" {
            if self.keyword.text == "" {
                self.view.showToast("Enter a valid query!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
                return false
                
            }
            return true
            
        }
        else {
            return true
        }
    }
    
    //pass the input data to the tab user page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tab = segue.destination as! MainTabBarViewController
//        let nav = tab.viewControllers?.first as! UINavigationController
//        let uvc = nav.viewControllers.first as! UserViewController
//        uvc.getstringuser = self.keyword.text!
        tab.getstring = self.keyword.text!
        


    }
    
    
    
    
    //search button action
    @IBAction func clicksearch(_ sender: UIButton) {
//        if self.keyword.text != "" {
//            let para: Parameters = [
//                "key":self.keyword.text!,
//                "tab":"user"
//            ]
//            
//            //use alamofire and swiftyjson to call php file
//            
//            Alamofire.request("http://sample-env-1.gjnvxzmmmm.us-west-1.elasticbeanstalk.com/ios.php", method: .get, parameters: para).validate().responseJSON { response in
//                switch response.result {
//                case .success(let value):
//                    let result = JSON(value)
//                    //print(result)
//                    //successfully get the string result here
//                    
//                    
//                case .failure(let error):
//                    print(error)
//                }
//                
//            }
//            
//        }
        

    }
    
    //clear button action
    
    @IBAction func clear(_ sender: Any) {
        self.keyword.text = ""
        
    }
    
    

    




}

