//
//  GroupViewController.swift
//  christyiosfirst
//
//  Created by chen tan on 4/17/17.
//  Copyright © 2017 chen tan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groupmenu: UIBarButtonItem!
    @IBOutlet weak var grouptableview: UITableView!
    @IBOutlet weak var groupNext: UIButton!
    @IBOutlet weak var groupPre: UIButton!
    
    
    //get the input text
    var groupstring = String()
    
    
    var groupArray = [AnyObject]()
    var groupnext = String()
    var grouppre = String()
    var groupid = String()
    var groupimg = String()
    var groupname = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SwiftSpinner.show(duration: 3.0, title: "Loading data...")
        
        // set slide out menu
        if revealViewController() != nil {
            groupmenu.target = revealViewController()
            groupmenu.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //get data from tabbar controller
        let tab = self.tabBarController as! MainTabBarViewController
        groupstring = tab.getstring
        
        //call alamofile
        
        let para: Parameters = [
            "key":groupstring,
            "tab":"group"
        ]
        
        Alamofire.request("http://35.226.10.223/ios.php", method: .get, parameters: para).validate().responseJSON { response in
            
            let result = response.result
            let dict = result.value as! Dictionary<String,AnyObject>
            let innerDict = dict["data"]
            if let next = dict["paging"]?["next"] {
                if next != nil {
                    self.groupnext = next as! String
                }
            }
            if let pre = dict["paging"]?["previous"] {
                if pre != nil {
                    self.grouppre = pre as! String
                }
                else {
                    self.groupPre.isEnabled = false
                }
            }
            self.groupArray = innerDict as! [AnyObject]
            self.grouptableview.reloadData()
            
        }
        
        //aovid extra rows
        self.grouptableview.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.grouptableview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //pass id to the tabbar controller
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupAP" {
            let tab = segue.destination as! GroupAPTabViewController
            tab.getid = groupid
            tab.getimg = groupimg
            tab.detailtitle = groupname
            
            
            //update back button title
            let backbutton = UIBarButtonItem()
            backbutton.title = "Results"
            navigationItem.backBarButtonItem = backbutton
        }
    }
    
    
    
    
    
    
    
    //output table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let groupCell = self.grouptableview.dequeueReusableCell(withIdentifier: "groupcell", for: indexPath) as! GroupTableViewCell
        
        //load picture
        let pic = groupArray[indexPath.row]["picture"] as? [String:Any]
        let picd = pic?["data"] as? [String:Any]
        let picURL = picd?["url"] as! String
        
        let url = URL(string: picURL)
        DispatchQueue.global().async {
            
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                groupCell.groupimg.image = UIImage(data: data!)
            }
        }
        
        //load name
        groupCell.groupname.text = groupArray[indexPath.row]["name"] as? String
        
        //pass id
        groupCell.passid = (groupArray[indexPath.row]["id"] as? String)!
        
        //pass image
        groupCell.passimg = picURL
        
        if let existuser = UserDefaults.standard.value(forKey: "groupappendidArray") {
            if (existuser as! [String]).contains(groupCell.passid) {
                groupCell.groupbtn.imageView?.image = UIImage(named:"filled")
            }else {
                groupCell.groupbtn.imageView?.image = UIImage(named:"empty")
            }
        }

        
        
        
        return groupCell
    }
    
    //pass id
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = grouptableview.indexPathForSelectedRow!
        let currentcell = grouptableview.cellForRow(at: indexPath) as! GroupTableViewCell
        self.groupid = currentcell.passid
        self.groupimg = currentcell.passimg
        self.groupname = currentcell.groupname.text!
        performSegue(withIdentifier: "groupAP", sender: self)
        
    }
    
    
    
    //page call
    func pageCall(url:String) {
        let para: Parameters = [
            "key":groupstring,
            "tab":"group"
        ]

        
        Alamofire.request(url, method: .get, parameters: para).validate().responseJSON { response in
            
            let result = response.result
            let dict = result.value as! Dictionary<String,AnyObject>
            let innerDict = dict["data"]
            if let next = dict["paging"]?["next"] {
                if next != nil {
                    self.groupnext = next as! String
                    self.groupNext.isEnabled = true
                }
                else {
                    self.groupNext.isEnabled = false
                }
            }
            if let pre = dict["paging"]?["previous"] {
                if pre != nil {
                    self.groupPre.isEnabled = true
                    self.grouppre = pre as! String
                }
                else {
                    self.groupPre.isEnabled = false
                }
                
            }
            self.groupArray = innerDict as! [AnyObject]
            self.grouptableview.reloadData()
            
            
            
        }
    }

    
    
    @IBAction func groupnextclick(_ sender: Any) {
        pageCall(url: groupnext)
    }

    
    @IBAction func grouppreclick(_ sender: Any) {
        pageCall(url: grouppre)
    }
    

}
