//
//  PageViewController.swift
//  christyiosfirst
//
//  Created by chen tan on 4/15/17.
//  Copyright © 2017 chen tan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class PageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var pagemenu: UIBarButtonItem!
    @IBOutlet weak var pagetableview: UITableView!
    @IBOutlet weak var pageNext: UIButton!
    @IBOutlet weak var pagePre: UIButton!
    
    var pageGetstring = String()
    //var names = ["abc"]
    //var images = [UIImage(named:"user")]
    
    var pageArray = [AnyObject]()
    var pagenext = String()
    var pagepre = String()
    
    var pageid = String()
    var pageimgurl = String()
    var pagename = String()
    
    
    var pageappendidArray:[String] = [] //id array
    var pageappendnameArray:[String] = [] //name array
    var pageappendimgArray:[String] = [] //img array
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SwiftSpinner.show(duration: 3.0, title: "Loading data...")
        
        if revealViewController() != nil {
            pagemenu.target = revealViewController()
            pagemenu.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //pass data from tabview controller to the page
        let tab = self.tabBarController as! MainTabBarViewController
        pageGetstring = tab.getstring
        print("the keyword can be output in the page:\(pageGetstring)")
        
        
        //call alamofire
        
        let para: Parameters = [
            "key":pageGetstring,
            "tab":"page"
        ]
        
        Alamofire.request("http://35.226.10.223/ios.php", method: .get, parameters: para).validate().responseJSON { response in
            
            let result = response.result
            let dict = result.value as! Dictionary<String,AnyObject>
            let innerDict = dict["data"]
            if let next = dict["paging"]?["next"] {
                if next != nil {
                    self.pagenext = next as! String
                }
            }
            if let pre = dict["paging"]?["previous"] {
                if pre != nil {
                    self.pagepre = pre as! String
                }
                else {
                    self.pagePre.isEnabled = false
                }
            }
            self.pageArray = innerDict as! [AnyObject]
            self.pagetableview.reloadData()
            
        }
        
        //aovid extra rows
        self.pagetableview.tableFooterView = UIView(frame: CGRect.zero)
        
        //woca()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pagetableview.reloadData()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //pass data to the pageAPtabcontroller
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pageAP" {
            let tab = segue.destination as! PageAPTabViewController
            tab.getid = self.pageid
            tab.geturl = self.pageimgurl
            tab.detailtitle = self.pagename
            
            //update back button title
            let backbutton = UIBarButtonItem()
            backbutton.title = "Results"
            navigationItem.backBarButtonItem = backbutton
        }
    }
    
    
    
    
    
    //output table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("number\(pageArray.count)")
        return pageArray.count
        
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pagecell = self.pagetableview.dequeueReusableCell(withIdentifier: "pagetablecell", for: indexPath) as! PageTableViewCell
        
        //load picture
        
        let pic = pageArray[indexPath.row]["picture"] as? [String:Any]
        let picd = pic?["data"] as? [String:Any]
        let picURL = picd?["url"] as! String
        
        let url = URL(string:picURL)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                pagecell.pageimg.image = UIImage(data: data!)
            }
        }
        
        //load name
        pagecell.pagename.text = pageArray[indexPath.row]["name"] as? String
        
        //load id
        pagecell.passid = (pageArray[indexPath.row]["id"] as? String)!
        
        //load image
        pagecell.passimg = picURL
        
        
        if let existuser = UserDefaults.standard.value(forKey: "pageappendidArray") {
            if (existuser as! [String]).contains(pagecell.passid) {
                pagecell.pagebtn.imageView?.image = UIImage(named:"filled")
            }else {
                pagecell.pagebtn.imageView?.image = UIImage(named:"empty")
            }
        }
        
        
        
        return pagecell
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = pagetableview.indexPathForSelectedRow!
        let currentcell = pagetableview.cellForRow(at: indexPath) as! PageTableViewCell
        self.pageid = currentcell.passid
        self.pageimgurl = currentcell.passimg
        self.pagename = currentcell.pagename.text!
        performSegue(withIdentifier: "pageAP", sender: self)
    }
    
    
    
    
    //page call
    
    func pageCall(url:String) {
        let para: Parameters = [
            "key":pageGetstring,
            "tab":"page"
        ]
        
        Alamofire.request(url, method: .get, parameters: para).validate().responseJSON{ response in
            let result = response.result
            let dict = result.value as! Dictionary<String,AnyObject>
            let innerDict = dict["data"]
            if let next = dict["paging"]?["next"] {
                if next != nil {
                    self.pagenext = next as! String
                    self.pageNext.isEnabled = true
                    
                }
                else {
                    self.pageNext.isEnabled = false
                }
            }
            if let pre = dict["paging"]?["previous"] {
                if pre != nil {
                    self.pagePre.isEnabled = true
                    self.pagepre = pre as! String
                }
                else {
                    self.pagePre.isEnabled = false
                }
            }
            self.pageArray = innerDict as! [AnyObject]
            self.pagetableview.reloadData()
        }
    }
    
    
    @IBAction func nextclick(_ sender: Any) {
        pageCall(url: pagenext)
    }
    
    
    @IBAction func preclick(_ sender: Any) {
        pageCall(url: pagepre)
    }
    
    
    //remove all remaining
    func woca() {
        //if id = [] or name = [] or img = [] then other two should be removed
        var IdArray = UserDefaults.standard.value(forKey: "pageappendidArray") as! [String]
        var ImgArray = UserDefaults.standard.value(forKey: "appendidArray") as! [String]
        var NameArray = UserDefaults.standard.value(forKey: "appendidArray") as! [String]
   
        
        if IdArray.count == 0 {
            if ImgArray.count > 0 {
                ImgArray.removeAll()
                UserDefaults.standard.set(ImgArray, forKey: "pageappendimgArray")
            }
            if NameArray.count > 0 {
                NameArray.removeAll()
                UserDefaults.standard.set(NameArray, forKey: "pageappendnameArray")
            }
        }
        if NameArray.count == 0 {
            if IdArray.count > 0 {
                IdArray.removeAll()
                UserDefaults.standard.set(IdArray, forKey: "pageappendidArray")
            }
            if ImgArray.count > 0 {
                ImgArray.removeAll()
                UserDefaults.standard.set(ImgArray, forKey: "pageappendimgArray")
            }
        }
        if ImgArray.count == 0 {
            if IdArray.count > 0 {
                IdArray.removeAll()
                UserDefaults.standard.set(IdArray, forKey: "pageappendidArray")
            }
            if NameArray.count > 0 {
                NameArray.removeAll()
                UserDefaults.standard.set(NameArray, forKey: "pageappendnameArray")
            }
        }
        
        UserDefaults.standard.synchronize()
        
    }
    
    func load() {
        if let localStorage = UserDefaults.standard.value(forKey: "pageappendidArray"){
            pageappendidArray = localStorage as! [String]
            print("pageid is:\(pageappendidArray)")
        }else {
            pageappendidArray = [String]()
        }
        
        if let localStoragename = UserDefaults.standard.value(forKey: "pageappendnameArray") {
            pageappendnameArray = localStoragename as! [String]
            print("pagename is:\(pageappendnameArray)")
        }else {
            pageappendnameArray = [String]()
        }
        
        if let localStorageimg = UserDefaults.standard.value(forKey: "pageappendimgArray") {
            pageappendimgArray = localStorageimg as! [String]
            print("pageimg is:\(pageappendimgArray)")
        }else {
            pageappendimgArray = [String]()
        }
    }
    
    

   

}
