//
//  GameViewController.swift
//  Toggelr
//
//  Created by Michel Georgy on 23/09/15.
//  Copyright © 2015 4eyes GmbH. All rights reserved.
//

import UIKit

class GoalDataItem : Equatable {
    var indexes : String = ""
    init(indexes : String) {
        self.indexes = indexes
    }
}
func ==(lhs: GoalDataItem, rhs: GoalDataItem) -> Bool {
    return lhs.indexes == rhs.indexes
}

class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var submitGameButton: UIButton!
    @IBOutlet weak var redGoals: UICollectionView!
    @IBOutlet weak var blueGoals: UICollectionView!
    

    var redTeam : [String] = [String]()
    var blueTeam : [String] = [String]()
    
    var data : [GoalDataItem] = [GoalDataItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...30 {
            let dataItem = GoalDataItem(indexes: String(i))
            self.data.append(dataItem)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelGame(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitGame(sender: AnyObject) {
        print("Team Red: @", redTeam)
        print("Team Blue: @", blueTeam)
        print("Red: @", redGoals.indexPathsForSelectedItems())
        print("Blue: @", blueGoals.indexPathsForSelectedItems())
        self.uploadRequest()
    }
    
    
    func uploadRequest()
    {
        let url:NSURL = NSURL(string: "https://toggelr.4eyes.ch/rest/X4E-x4etoggelr-game")!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
       
        var redGoal = "0";
        var blueGoal = "0";
        for redIndexPath in redGoals.indexPathsForSelectedItems()! {
            if let redCell = redGoals.cellForItemAtIndexPath(redIndexPath) as? GoalCell {
                redGoal = redCell.label.text!
                print(redGoal);
            }
        }
        for blueIndexPath in blueGoals.indexPathsForSelectedItems()! {
            if let blueCell = blueGoals.cellForItemAtIndexPath(blueIndexPath) as? GoalCell {
                blueGoal = blueCell.label.text!
                print(blueGoal);
            }
        }
        
        let dataString: String = "redp1=\(redTeam[0])&redp2=\(redTeam[1])&bluep1=\(blueTeam[0])&bluep2=\(blueTeam[1])&red=\(redGoal)&blue=\(blueGoal)";
        print(dataString);
        let data = dataString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: data, completionHandler:
            {(data,response,error) in
                
                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    let alert = UIAlertController(title: "Error", message: "Error uploading result", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
                
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(dataString)
                let alert = UIAlertController(title: "Submitted", message: "Your result has been uploaded!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: {
                    action in
                        // todo: close result view
                        //self.navigationController?.popViewControllerAnimated(true)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        );
        
        task.resume()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("select")
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if(cell != nil){
            let cell = cell as! GoalCell
//        cell.backgroundColor = UIColor.whiteColor()
//        cell.label.textColor = UIColor.blackColor()
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        print("deselect")
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if(cell != nil){
            let cell = cell as! GoalCell
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clearColor().CGColor
        }

        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK : UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GoalCell", forIndexPath: indexPath) as! GoalCell
        
        let dataItem = data[indexPath.item]
        cell.label.text = dataItem.indexes
        
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 0

        /*cell.imageView.image = UIImage(data: dataItem.image)
        //
        //        cell.backgroundColor = dataItem.colour
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.masksToBounds = false
        cell.imageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.imageView.layer.cornerRadius = 30
        cell.imageView.clipsToBounds = true

        
        cell.hidden = false
        */
        
        return cell
    }
    
    // MARK : KDDragAndDropCollectionViewDataSource
   /*
    func collectionView(collectionView: UICollectionView, dataItemForIndexPath indexPath: NSIndexPath) -> AnyObject {
        return data[indexPath.item]
    }
    func collectionView(collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: NSIndexPath) -> Void {
        
        if let di = dataItem as? DataItem {
            data.insert(di, atIndex: indexPath.item)
        }
        
        
    }
    func collectionView(collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath : NSIndexPath) -> Void {
        data[collectionView.tag].removeAtIndex(indexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView, moveDataItemFromIndexPath from: NSIndexPath, toIndexPath to : NSIndexPath) -> Void {
        
        let fromDataItem: DataItem = data[collectionView.tag][from.item]
        data[collectionView.tag].removeAtIndex(from.item)
        data[collectionView.tag].insert(fromDataItem, atIndex: to.item)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: to) as! ColorCell
        cell.hidden = false
        collectionView.reloadData()
        
    }
    
    func collectionView(collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> NSIndexPath? {
        
        if let candidate : DataItem = dataItem as? DataItem {
            
            for item : DataItem in data[collectionView.tag] {
                if candidate  == item {
                    
                    let position = data[collectionView.tag].indexOf(item)! // ! if we are inside the condition we are guaranteed a position
                    let indexPath = NSIndexPath(forItem: position, inSection: 0)
                    return indexPath
                }
            }
        }
        
        return nil
        
    }
*/
}
