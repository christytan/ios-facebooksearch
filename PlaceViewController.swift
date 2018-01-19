//
//  PlaceViewController.swift
//  christyiosfirst
//
//  Created by chen tan on 4/16/17.
//  Copyright © 2017 chen tan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class PlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var placemenu: UIBarButtonItem!
    @IBOutlet weak var placetableview: UITableView!
 
    @IBOutlet weak var placePre: UIButton!
    @IBOutlet weak var placeNext: UIButton!
    
    
    
    var placestring = String()
    var placeArray = [AnyObject]()
    var placenext = String()
    var placepre = String()
    var placeid = String()
    var placeimg = String()
    var placename = String()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SwiftSpinner.show(duration: 3.0, title: "Loading data...")
        
        if revealViewController() != nil {
            placemenu.target = revealViewController()
            placemenu.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //pass data from tabview controller to the page
        let tab = self.tabBarController as! MainTabBarViewController
        placestring = tab.getstring
        
        
        //call alamofire
        let para: Parameters = [
            "key":placestring,
            "tab":"place",
            "lat":"34.0225483",
            "lng":"-118.2818853"
        ]
        
        Alamofire.request("http://35.226.10.223/ios.php", method: .get, parameters: para).validate().responseJSON { response in
            let result = response.result
            if result.value != nil {
                let dict = result.value as! Dictionary<String,AnyObject>
                let innerDict = dict["data"]
                if let next = dict["paging"]?["next"] {
                    if next != nil {
                        self.placenext = next as! String
                    }
                }
                if let pre = dict["paging"]?["previous"] {
                    if pre != nil {
                        self.placepre = pre as! String
                    }
                    else {
                        self.placePre.isEnabled = false
                    }
                }

                self.placeArray = innerDict as! [AnyObject]
            }
            
            self.placetableview.reloadData()
            
        }
        
        //aovid extra rows
        self.placetableview.tableFooterView = UIView(frame: CGRect.zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.placetableview.reloadData()
    }
    
    
    //pass data to the self.tab bar
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "placeAP" {
            let tab = segue.destination as! PlaceAPTabViewController
            tab.getid = self.placeid
            tab.getimgurl = self.placeimg
            tab.detailtitle = self.placename
            
            
            
            //update back button title
            let backbutton = UIBarButtonItem()
            backbutton.title = "Results"
            navigationItem.backBarButtonItem = backbutton
        }
    }
    
    //output table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeCell = self.placetableview.dequeueReusableCell(withIdentifier: "placecell", for: indexPath) as! PlaceTableViewCell
        
        //load picture
        let pic = placeArray[indexPath.row]["picture"] as? [String:Any]
        let picd = pic?["data"] as? [String:Any]
        let picURL = picd?["url"] as! String
        
        let url = URL(string:picURL)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                placeCell.placeimg.image = UIImage(data: data!)
            }
        }
        //load name
        placeCell.placename.text = placeArray[indexPath.row]["name"] as? String
        
        //load id
        placeCell.passid = (placeArray[indexPath.row]["id"] as? String)!
        
        //load image
        placeCell.passimgurl = picURL
        
        if let existuser = UserDefaults.standard.value(forKey: "placeappendidArray") {
            if (existuser as! [String]).contains(placeCell.passid) {
                placeCell.placebtn.imageView?.image = UIImage(named:"filled")
            }else {
                placeCell.placebtn.imageView?.image = UIImage(named:"empty")
            }
        }
        
        
        
        
        
     
        
        return placeCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = placetableview.indexPathForSelectedRow!
        let currentcell = placetableview.cellForRow(at: indexPath) as! PlaceTableViewCell
        self.placeid = currentcell.passid
        self.placeimg = currentcell.passimgurl
        self.placename = currentcell.placename.text!
        performSegue(withIdentifier: "placeAP", sender: self)
    }
    
    
    
    
    
    //page call
    func pageCall(url:String) {
        let para: Parameters = [
            "key":placestring,
            "tab":"place"
        ]
        
        Alamofire.request(url, method: .get, parameters: para).validate().responseJSON{ response in
            let result = response.result
            let dict = result.value as! Dictionary<String,AnyObject>
            let innerDict = dict["data"]
            if let next = dict["paging"]?["next"] {
                
                if next != nil {
                    self.placeNext.isEnabled = true
                    self.placenext = next as! String
                    
                }
                else {
                    self.placeNext.isEnabled = false
                }
            }
            if let pre = dict["paging"]?["previous"] {
                if pre != nil {
                    self.placePre.isEnabled = true
                    self.placepre = pre as! String
                }
                else {
                    self.placePre.isEnabled = false
                }
            }
            self.placeArray = innerDict as! [AnyObject]
            self.placetableview.reloadData()
        }
    }

    
    @IBAction func placeclickpre(_ sender: Any) {
        pageCall(url: placepre)
    }

    
    @IBAction func placeclicknext(_ sender: Any) {
        pageCall(url: placenext)
    }
    
    

   

}
