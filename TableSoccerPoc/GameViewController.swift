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
    @IBOutlet weak var cancelButton: UIButton!
    
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
    

    @IBAction func cancelGame(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitGame(_ sender: AnyObject) {
        self.submitGameButton.isEnabled = false;
        
        print("Team Red: @", redTeam)
        print("Team Blue: @", blueTeam)
        print("Red: @", redGoals.indexPathsForSelectedItems)
        print("Blue: @", blueGoals.indexPathsForSelectedItems)
        self.uploadRequest()
    }
    
    
    func uploadRequest()
    {
        let url:URL = URL(string: Constants.Url.Game)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
       
        var redGoal = "0";
        var blueGoal = "0";
        for redIndexPath in redGoals.indexPathsForSelectedItems! {
            if let redCell = redGoals.cellForItem(at: redIndexPath) as? GoalCell {
                redGoal = redCell.label.text!
                print(redGoal);
            }
        }
        for blueIndexPath in blueGoals.indexPathsForSelectedItems! {
            if let blueCell = blueGoals.cellForItem(at: blueIndexPath) as? GoalCell {
                blueGoal = blueCell.label.text!
                print(blueGoal);
            }
        }
        
        let dataString: String = "redp1=\(redTeam[0])&redp2=\(redTeam[1])&bluep1=\(blueTeam[0])&bluep2=\(blueTeam[1])&red=\(redGoal)&blue=\(blueGoal)";
        print(dataString);
        let data = dataString.data(using: String.Encoding.utf8)
        
        let task = session.uploadTask(with: request as URLRequest, from: data, completionHandler:
            {(data,response,error) in
                
                guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                    print("error")
                    let alert = UIAlertController(title: "Error", message: "Error uploading result", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                    DispatchQueue.global(qos: .background).async {
                        DispatchQueue.main.async {
                           self.present(alert, animated: true, completion: nil)
                        }
                    }
                
                    return
                }
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                let alert = UIAlertController(title: "Submitted", message: "Your result has been uploaded!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: {
                    action in
                        // todo: close result view
                        //self.navigationController?.popViewControllerAnimated(true)
                }))
                self.submitGameButton.isEnabled = true;
                
                DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.async {
                       self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        );
        
        task.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select")
        let cell = collectionView.cellForItem(at: indexPath)
        if(cell != nil){
            let cell = cell as! GoalCell
//        cell.backgroundColor = UIColor.whiteColor()
//        cell.label.textColor = UIColor.blackColor()
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor.white.cgColor
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselect")
        let cell = collectionView.cellForItem(at: indexPath)
        if(cell != nil){
            let cell = cell as! GoalCell
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoalCell", for: indexPath) as! GoalCell
        
        let dataItem = data[(indexPath as NSIndexPath).item]
        cell.label.text = dataItem.indexes
        
        cell.layer.borderColor = UIColor.white.cgColor
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
