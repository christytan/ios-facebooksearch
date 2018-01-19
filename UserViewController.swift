//
//  UserViewController.swift
//  christyiosfirst
//
//  Created by chen tan on 4/13/17.
//  Copyright © 2017 chen tan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var usertableview: UITableView!
    @IBOutlet weak var usermenu: UIBarButtonItem!
    
    
    @IBOutlet weak var userNext: UIButton!
    @IBOutlet weak var userPre: UIButton!
    
    //get the input text
    var getstringuser = String()
    
    
    var userArray = [AnyObject]()
    var userPage = String()
    var userpre = String()
    var userid = String()
    var userimg = String()
    var username = String()
    
    //favorite string
    var fimg = String()
    var fname = String()
    var favoritearray = [[Any]]()
    var truefalse = [Bool]()
    
    
   
    
    //starbtn is clickflag to the AP page
    var isclick = false
    
    //starbtn should change or not by option menu
    var shouldChange = false
    
    //index of selected rows
    var rows = Int()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        SwiftSpinner.show(duration: 3.0, title: "Loading data...")
        
        userNext.setTitle("Next", for: .normal)

        // set slide out menu
        if revealViewController() != nil {
            usermenu.target = revealViewController()
            usermenu.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //get data from tabbar controller
        let tab = self.tabBarController as! MainTabBarViewController
        getstringuser = tab.getstring
        
     
        
        //call alamofile
        
        let para: Parameters = [
            "key":getstringuser,
            "tab":"user"
        ]
    
        Alamofire.request("http://35.226.10.223/ios.php", method: .get, parameters: para).validate().responseJSON { response in
            
                let result = response.result
                let dict = result.value as! Dictionary<String,AnyObject>
                let innerDict = dict["data"]
                if let next = dict["paging"]?["next"] {
                    if next != nil {
                        self.userPage = next as! String
                    }
                }
                if let pre = dict["paging"]?["previous"] {
                    if pre != nil {
                        self.userpre = pre as! String
                    }
                    else {
                        self.userPre.isEnabled = false
                    }
                }
                self.userArray = innerDict as! [AnyObject]
                self.usertableview.reloadData()
            
        }
        
        //aovid extra rows
        self.usertableview.tableFooterView = UIView(frame: CGRect.zero)
                
     
    
    }
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear(animated)
        self.usertableview.reloadData()

        
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //pass data to the album and post tab bar controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userAP" {
            
            let tab = segue.destination as! APUserViewController
            tab.id = self.userid
            tab.imgurl = self.userimg
            tab.detailtitle = self.username
            tab.starclick = self.isclick
            
            
            //protocol pass back data
            //tab.myprotocol = self
            
            
            
            //update back button title
            let backbutton = UIBarButtonItem()
            backbutton.title = "Results"
            navigationItem.backBarButtonItem = backbutton
            
        }
    }
    
  
    
    
    
    
    //output table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    //fill each table cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let usercell = self.usertableview.dequeueReusableCell(withIdentifier: "usertabcell", for: indexPath) as! UserTableViewCell
        
        //load picture
        let pic = userArray[indexPath.row]["picture"] as? [String:Any]
        let picd = pic?["data"] as? [String:Any]
        let picURL = picd?["url"] as! String
        
        let url = URL(string: picURL)
        DispatchQueue.global().async {
            
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                usercell.userimg.image = UIImage(data: data!)
            }
        }
        
        //load name
        usercell.username.text = userArray[indexPath.row]["name"] as? String
        
        //load id
        usercell.passid = (userArray[indexPath.row]["id"] as? String)!
        
        //load img
        usercell.passimg = picURL
        
        //load favorite
        usercell.starbtn.tag = indexPath.row
        usercell.starbtn.addTarget(self, action: #selector(UserViewController.favoritebtn(_:)), for: UIControlEvents.touchUpInside)

 
        
        if let existuser = UserDefaults.standard.value(forKey: "appendidArray") {
            if (existuser as! [String]).contains(usercell.passid) {
                usercell.starbtn.imageView?.image = UIImage(named:"filled")
            }else {
                usercell.starbtn.imageView?.image = UIImage(named:"empty")
            }
        }
        
      
        
        return usercell
    }
    
    //return id
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = usertableview.indexPathForSelectedRow!
        let currentcell = usertableview.cellForRow(at: indexPath) as! UserTableViewCell
        self.userid = currentcell.passid
        self.userimg = currentcell.passimg
        self.username = currentcell.username.text!
        if currentcell.starbtn.imageView?.image == UIImage(named:"filled") {
            self.isclick = true
        }
        else {
            self.isclick = false
        }
        //get the index of selected cell
        let test = self.usertableview.indexPathsForSelectedRows?.map{$0.row}
        self.rows = (test?[0])!
        
        performSegue(withIdentifier: "userAP", sender: self)
        
    }
    
    
    
    
    
    
    //page call
    func pageCall(url:String) {
        let para: Parameters = [
            "key":getstringuser,
            "tab":"user"
        ]
    
        
        Alamofire.request(url, method: .get, parameters: para).validate().responseJSON { response in
        
            let result = response.result
            let dict = result.value as! Dictionary<String,AnyObject>
            let innerDict = dict["data"]
            if let next = dict["paging"]?["next"] {
                if next != nil {
                    self.userPage = next as! String
                    self.userNext.isEnabled = true
                }
                else {
                    self.userNext.isEnabled = false
                }
            }
            if let pre = dict["paging"]?["previous"] {
                if pre != nil {
                    self.userPre.isEnabled = true
                    self.userpre = pre as! String
                }
                else {
                    self.userPre.isEnabled = false
                }
                
            }
            self.userArray = innerDict as! [AnyObject]
            self.usertableview.reloadData()
            
            
            
        }
    }
    
    //Next button
    
    @IBAction func NextPage(_ sender: Any) {
        pageCall(url:userPage)
    }
    
    //previous button
    
    @IBAction func PrePage(_ sender: Any) {
        pageCall(url:userpre)
    }
    
 
    
    @IBAction func favoritebtn(_ sender: Any) {
 
    }
    
}
