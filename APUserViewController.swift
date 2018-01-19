//
//  APUserViewController.swift
//  christyiosfirst
//
//  Created by chen tan on 4/17/17.
//  Copyright © 2017 chen tan. All rights reserved.
//

import UIKit
import EasyToast
import FBSDKShareKit


class APUserViewController: UITabBarController, FBSDKSharingDelegate {
    
    var id = String()
    var detailtitle = String()
    var imgurl = String()
    var alertitle = "Add to favorites"
    var starclick = Bool()
    var starchangeimg = false //bool pass back
    //var myprotocol : writevaluebackDelegate?
    
    var appendidArray:[String] = [] //id array
    var appendnameArray:[String] = [] //name array
    var appendimgArray:[String] = [] //img array
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFromLocalStorage()
        woca()
    }
    
    
    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        view.showToast("failed", position: .bottom, popTime: 3, dismissOnTap: true)
    }
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        view.showToast("success", position: .bottom, popTime: 3, dismissOnTap: true)
    }
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        view.showToast("cancel", position: .bottom, popTime: 3, dismissOnTap: true)
    }
    
   
    
    @IBAction func useroption(_ sender: Any) {
        let useralert : UIAlertController = UIAlertController(title:"Menu", message: nil, preferredStyle: .actionSheet)

        let useraddfavorite = UIAlertAction(title: "Added to favorites", style:.default, handler: {action in self.favorite()})
        let userdeletefavorite = UIAlertAction(title: "Remove from favorites", style:.default, handler: {action in self.remove()})
        let usershare = UIAlertAction(title: "Share", style:.default, handler: {action in self.share()})
        let usercancel = UIAlertAction(title: "Cancel", style:.default, handler: nil)
        
        
        if let checkExistence = UserDefaults.standard.value(forKey: "appendidArray") {
            
            //if user not exist in the userdefault
            if !(checkExistence as! [String]).contains(self.id) {
                useralert.addAction(useraddfavorite)
                
            }
            else {
                useralert.addAction(userdeletefavorite)
            }
      
            
        }
        else {
            useralert.addAction(useraddfavorite)
        }
        
        
        useralert.addAction(usershare)
        useralert.addAction(usercancel)
        self.present(useralert, animated: true, completion: nil)
        
    }
    
    func favorite() {
        self.view.showToast("Added to favorites", position: .bottom, popTime: 2, dismissOnTap: true)
       
        //guarantee each of the id is currentcell.id
        appendidArray.append(self.id) //store appointed id to the appendid array
        UserDefaults.standard.set(self.appendidArray, forKey: "appendidArray")
        
        //store username into the local storage
        appendnameArray.append(self.detailtitle)
        UserDefaults.standard.set(self.appendnameArray, forKey: "appendnameArray")
        
        //store userimg into the local storage
        appendimgArray.append(self.imgurl)
        UserDefaults.standard.set(self.appendimgArray, forKey: "appendimgArray")
        
        
        UserDefaults.standard.synchronize()
        

        
        
    }
    
    //very important load function
    func loadFromLocalStorage() {
        if let localStorage = UserDefaults.standard.value(forKey: "appendidArray"){
            appendidArray = localStorage as! [String]
            print("id is:\(appendidArray)")
        }else {
            appendidArray = []
        }
        
        if let localStoragename = UserDefaults.standard.value(forKey: "appendnameArray") {
            appendnameArray = localStoragename as! [String]
            print("name is:\(appendnameArray)")
        }else {
            appendnameArray = []
        }
        
        if let localStorageimg = UserDefaults.standard.value(forKey: "appendimgArray") {
            appendimgArray = localStorageimg as! [String]
            print("img is:\(appendimgArray)")
        }else {
            appendimgArray = []
        }
        
    }
    
    
    func remove() {
        //remove the append
        self.view.showToast("Removed to favorites", position: .bottom, popTime: 2, dismissOnTap: true)
        //find the appointed id and remove it
        
        var IdArray = UserDefaults.standard.value(forKey: "appendidArray") as! [String]
        if let index = IdArray.index(of: self.id) {
            IdArray.remove(at: index)
        }
        UserDefaults.standard.set(IdArray, forKey: "appendidArray")
        
        //find the appointed name and remove it
        var NameArray = UserDefaults.standard.value(forKey: "appendnameArray") as! [String]
        if let nameindex = NameArray.index(of: self.detailtitle) {
            NameArray.remove(at: nameindex)
        }
        UserDefaults.standard.set(NameArray, forKey: "appendnameArray")
        
        //find the appointed img and remove it
        var ImgArray = UserDefaults.standard.value(forKey: "appendimgArray") as! [String]
        if let imgindex = ImgArray.index(of: self.imgurl) {
            ImgArray.remove(at: imgindex)
        }
        UserDefaults.standard.set(ImgArray, forKey: "appendimgArray")
        UserDefaults.standard.synchronize()
        
        
        
    }
    
    
    
    //share to facebook
    func share() {
        //self.view.showToast("clicked share button!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        //pop out the facebook output 
        
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = URL(string: imgurl)
        content.contentTitle = self.detailtitle
        content.contentDescription = "FB Share for CSCI 571"
        content.imageURL = URL(string:imgurl)
  
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogMode.feedBrowser
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.delegate = self
        dialog.show()
    
    }
    
    
    //remove all remaining
    func woca() {
        //if id = [] or name = [] or img = [] then other two should be removed
        if appendidArray.count == 0 {
            if appendimgArray.count > 0 {
                appendimgArray.removeAll()
                UserDefaults.standard.set(appendimgArray, forKey: "appendimgArray")
            }
            if appendnameArray.count > 0 {
                appendnameArray.removeAll()
                UserDefaults.standard.set(appendnameArray, forKey: "appendnameArray")
            }
        }
        if appendnameArray.count == 0 {
            if appendidArray.count > 0 {
                appendidArray.removeAll()
                UserDefaults.standard.set(appendidArray, forKey: "appendidArray")
            }
            if appendimgArray.count > 0 {
                appendimgArray.removeAll()
                UserDefaults.standard.set(appendimgArray, forKey: "appendimgArray")
            }
        }
        if appendimgArray.count == 0 {
            if appendidArray.count > 0 {
                appendidArray.removeAll()
                UserDefaults.standard.set(appendidArray, forKey: "appendidArray")
            }
            if appendnameArray.count > 0 {
                appendnameArray.removeAll()
                UserDefaults.standard.set(appendnameArray, forKey: "appendnameArray")
            }
        }
        
        UserDefaults.standard.synchronize()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
