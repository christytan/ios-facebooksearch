//
//  FPagePostViewController.swift
//  christyiosfirst
//
//  Created by chen tan on 4/23/17.
//  Copyright © 2017 chen tan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import EasyToast

class FPagePostViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var fpageposttableview: UITableView!
    
    
    var id = String()
    var imgurl = String()
    var array = [AnyObject]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        SwiftSpinner.show(duration: 3.0, title: "Loading data...")
        
        //get id from tab bar
        
        let tab = self.tabBarController as! FPageTabViewController
        id = tab.getid
        imgurl = tab.geturl
        
        //call alamofire
        let para: Parameters = [
            "id":id
        ]
        
        
        Alamofire.request("http://35.226.10.223/ios.php", method: .get, parameters: para).validate().responseJSON { response in
            
            let result = response.result
            let dict = result.value as! Dictionary<String,AnyObject>
            let innerDict = dict["posts"]?["data"]
            if innerDict != nil {
                self.array = innerDict as! [AnyObject]
            }
            
            
            
            self.fpageposttableview.reloadData()

        }
        
        //auto resizing row height
        self.fpageposttableview.estimatedRowHeight = 140.0
        self.fpageposttableview.rowHeight = UITableViewAutomaticDimension
        
        //avoid extra empty row
        self.fpageposttableview.tableFooterView = UIView(frame: CGRect.zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.fpageposttableview.dequeueReusableCell(withIdentifier: "fpagepostcell", for: indexPath) as! FPagePostTableViewCell
        
        //get image from page view controller
        
        let url = URL(string: self.imgurl)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                cell.fpagepostimg.image = UIImage(data: data!)
            }
        }
        
        //get post content
        let message = array[indexPath.row]["message"] as? String
        if message != nil {
            cell.fpagepostcontent.text = array[indexPath.row]["message"] as? String
        }
        else {
            cell.fpagepostcontent.text = "No data found"
        }
        
        
        
        //string to date
        
        let datestring = array[indexPath.row]["created_time"] as? String
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        //dateFormatter.dateFormat = "dd MMM yyyy hh:mm:ss"
        dateFormatter.date(from: datestring!)
        
        //date to string
        let outputdate = dateFormatter.date(from: datestring!)!
        let dateF = DateFormatter()
        dateF.dateFormat = "dd MMM yyyy HH:mm:ss"
        let dateString = dateF.string(from: outputdate)
        
        //get post date
        cell.fpagepostdate.text = dateString
        
        
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if array.count>0 {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data found"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections

    }

    

}
