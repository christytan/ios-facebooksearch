//
//  PageAlbumViewController.swift
//  christyiosfirst
//
//  Created by chen tan on 4/18/17.
//  Copyright © 2017 chen tan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner




class PageAlbumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var pagealbumtableview: UITableView!
    

    
    var id = String()
    var array = [AnyObject]()
    var selectedIndexPath:NSIndexPath?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SwiftSpinner.show(duration: 3.0, title: "Loading data...")
        
        //get data from tabbar controller
        let tab = self.tabBarController as! PageAPTabViewController
        id = tab.getid
        
        
        //call alamofire
        let para: Parameters = [
            "id":id
        ]
        //print("id in page album is:\(id)")

        Alamofire.request("http://35.226.10.223/ios.php", method: .get, parameters: para).validate().responseJSON { response in

            let result = response.result
            if result.value != nil {
                let dict = result.value as! Dictionary<String,AnyObject>
                let innerDict = dict["albums"]?["data"]
                if innerDict != nil {
                    self.array = innerDict as! [AnyObject]
                }
                
                self.pagealbumtableview.reloadData()
            }
            
            
            
        }
        
        self.pagealbumtableview.tableFooterView = UIView(frame: CGRect.zero)
    
        
        
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.pagealbumtableview.dequeueReusableCell(withIdentifier: "palbumcell", for: indexPath) as! PageAlbumTableViewCell
        




        //load name
        cell.palbumname.text = array[indexPath.row]["name"] as? String
        

        //load image

        let pic = array[indexPath.row]["photos"] as? [String:Any]
        
        if pic != nil {
            //count the album picture number
            let arraypic = pic?["data"] as! [AnyObject]
            
            if let picpd = pic?["data"] as? [[String:Any]] {
                var i = 0
                let pidd = picpd[i]
                let picURL = pidd["picture"] as! String
                //print("firstpic:\(picURL)")
                let url = URL(string: picURL)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        cell.palbumpicone.image = UIImage(data: data!)
                    }
                }
                
                i += 1
                
                
                if i+1 == arraypic.count {
                    
                    let pidtwo = picpd[1]
                    let picURLtwo = pidtwo["picture"] as! String
                    let urltwo = URL(string:picURLtwo)
                    //print("firstpic:\(picURLtwo)")
                    DispatchQueue.global().async {
                        let datatwo = try? Data(contentsOf: urltwo!)
                        DispatchQueue.main.async {
                            cell.palbumtwo.image = UIImage(data:datatwo!)
                        }
                    }
                }
            }
        }
       
        

     
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
    
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath
        if indexPath as NSIndexPath == selectedIndexPath {
            selectedIndexPath = nil
        }
        else {
            selectedIndexPath = indexPath as NSIndexPath
        }
        var indexPaths : Array<NSIndexPath> = []
        if let previous = previousIndexPath {
            indexPaths += [previous]
        }
        if let current = selectedIndexPath {
            indexPaths += [current]
        }
        if indexPaths.count > 0 {
            tableView.reloadRows(at: indexPaths as [IndexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! PageAlbumTableViewCell).watchFrameChanges()
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! PageAlbumTableViewCell).ignoreFrameChanges()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath as NSIndexPath == selectedIndexPath {
            return PageAlbumTableViewCell.expandedHeight
        }
        else {
            return PageAlbumTableViewCell.defaultHeight
        }
    }
    
    
    
    
}
