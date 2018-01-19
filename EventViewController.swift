//
//  EventViewController.swift
//  christyiosfirst
//
//  Created by chen tan on 4/16/17.
//  Copyright © 2017 chen tan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var eventmenu: UIBarButtonItem!
    @IBOutlet weak var eventtableview: UITableView!
    
    @IBOutlet weak var eventPre: UIButton!
    @IBOutlet weak var eventNext: UIButton!
    
    
    var eventstring = String()
    
    var eventArray = [AnyObject]()
    var eventnext = String()
    var eventpre = String()
    var eventid = String()
    var eventimg = String()
    var eventname = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.show(duration: 3.0, title: "Loading data...")

        if revealViewController() != nil {
            eventmenu.target = revealViewController()
            eventmenu.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //pass data from tabview controller to the page
        let tab = self.tabBarController as! MainTabBarViewController
        eventstring = tab.getstring
        
        //call alamofire
        
        let para: Parameters = [
            "key":eventstring,
            "tab":"event"
        ]
        
        Alamofire.request("http://35.226.10.223/ios.php", method: .get, parameters: para).validate().responseJSON { response in
            let result = response.result
            let dict = result.value as! Dictionary<String,AnyObject>
            let innerDict = dict["data"]
            if let next = dict["paging"]?["next"] {
                if next != nil {
                    self.eventnext = next as! String
                }
            }
            if let pre = dict["paging"]?["previous"] {
                if pre != nil {
                    self.eventpre = pre as! String
                }
                else {
                    self.eventPre.isEnabled = false
                }
            }
            self.eventArray = innerDict as! [AnyObject]
            self.eventtableview.reloadData()

        }
        
        //aovid extra rows
        self.eventtableview.tableFooterView = UIView(frame: CGRect.zero)
        


    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.eventtableview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventAP" {
            let tab = segue.destination as! EventAPTabViewController
            tab.getid = eventid
            tab.getimg = eventimg
            tab.detailtitle = eventname
            
            
            //update back button title
            let backbutton = UIBarButtonItem()
            backbutton.title = "Results"
            navigationItem.backBarButtonItem = backbutton
        }
        
    }
    
    
    
    
    //output table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventcells = self.eventtableview.dequeueReusableCell(withIdentifier: "eventcell", for: indexPath) as! eventTableViewCell
        
        //load picture
        
        let pic = eventArray[indexPath.row]["picture"] as? [String:Any]
        let picd = pic?["data"] as? [String:Any]
        let picURL = picd?["url"] as! String
        
        let url = URL(string:picURL)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                eventcells.eventimage.image = UIImage(data: data!)
            }
        }
        
        //load name
        eventcells.eventname.text = eventArray[indexPath.row]["name"] as? String
        
        eventcells.passid = (eventArray[indexPath.row]["id"] as? String)!
        
        eventcells.passimg = picURL
        
        if let existuser = UserDefaults.standard.value(forKey: "eventappendidArray") {
            if (existuser as! [String]).contains(eventcells.passid) {
                eventcells.eventbtn.imageView?.image = UIImage(named:"filled")
            }else {
                eventcells.eventbtn.imageView?.image = UIImage(named:"empty")
            }
        }
        
       
        
        return eventcells
        
    }
    
    //pass id
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = eventtableview.indexPathForSelectedRow!
        let currentcell = eventtableview.cellForRow(at: indexPath) as! eventTableViewCell
        self.eventid = currentcell.passid
        self.eventimg = currentcell.passimg
        self.eventname = currentcell.eventname.text!
        performSegue(withIdentifier: "eventAP", sender: self)
        
    }
    
    
    
    //page call
    
    func pageCall(url:String) {
        let para: Parameters = [
            "key":eventstring,
            "tab":"event"
        ]
        
        Alamofire.request(url, method: .get, parameters: para).validate().responseJSON{ response in
            let result = response.result
            let dict = result.value as! Dictionary<String,AnyObject>
            let innerDict = dict["data"]
            if let next = dict["paging"]?["next"] {
                
                if next != nil {
                    //self.eventNext.isEnabled = true
                    self.eventnext = next as! String
                    
                }
                else {
                    //self.eventNext.isEnabled = false
                }
            }
            if let pre = dict["paging"]?["previous"] {
                if pre != nil {
                    self.eventPre.isEnabled = true
                    self.eventpre = pre as! String
                }
                else {
                    self.eventPre.isEnabled = false
                }
            }
            self.eventArray = innerDict as! [AnyObject]
            self.eventtableview.reloadData()
        }
    }
    
    
    @IBAction func clicknext(_ sender: Any) {
        pageCall(url: eventnext)
    }
    
    

    @IBAction func clickpre(_ sender: Any) {
        pageCall(url: eventpre)
    }
   

}
