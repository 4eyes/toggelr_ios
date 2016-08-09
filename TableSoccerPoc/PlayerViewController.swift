
//
//  ViewController.swift
//  TableSoccerPoc
//
//  Created by Michel Georgy on 10/09/15.
//  Copyright (c) 2015 4eyes GmbH. All rights reserved.
//

import UIKit

class DataItem : Equatable {
    
    var indexes : String!
    var image : NSData!
    init(indexes : String, image : NSData) {
        self.indexes = indexes
        print(indexes);
        self.image = image
    }
}

func ==(lhs: DataItem, rhs: DataItem) -> Bool {
    return lhs.indexes == rhs.indexes
}

class ViewController: UIViewController, KDDragAndDropCollectionViewDataSource, NSURLConnectionDelegate {
        
    @IBOutlet weak var TeamRed: UICollectionView!
    @IBOutlet weak var TeamBlue: UICollectionView!
    @IBOutlet weak var Players: UICollectionView!
    
    @IBOutlet weak var loadingSign: UIActivityIndicatorView!
    
    var data : [[DataItem]] = [[DataItem]]()
    
    var jsonData = NSMutableData()
    
    var dragAndDropManager : KDDragAndDropManager?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for i in 0...2 {
            
            let items = [DataItem]()
           /* if i == 1 {
                for j in 0...1 {
                    
                    let dataItem = DataItem(indexes: String(i) + ":" + String(j))
                    
                    items.append(dataItem)
                    
                }
            }
            */
            self.data.append(items)
        }
        
        self.dragAndDropManager = KDDragAndDropManager(canvas: self.view, collectionViews: [TeamRed, Players, TeamBlue])

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//                startConnection()
    }
    
    override func viewDidAppear(animated: Bool) {
        startConnection()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "newgame"){
            let gameViewController = segue.destinationViewController as! GameViewController
            var redTeam = [String]()
            var blueTeam = [String]()
            
            for player in self.data[0] {
                if let id = player.indexes {
                    print(id)
                    redTeam.append(id)
                }
            }
            for player in self.data[2] {
                if let id = player.indexes {
                    print(id)
                    blueTeam.append(id)
                }
            }
            
            gameViewController.redTeam = redTeam
            gameViewController.blueTeam = blueTeam
        }
    }
    
    @IBAction func showStatistics(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://toggelr.4eyes.ch")!)
    }
    
    func startConnection(){
        let urlPath: String = "https://toggelr.4eyes.ch/rest/X4E-x4etoggelr-player"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData jsonData: NSData!){
        self.jsonData.appendData(jsonData)
    }
    
    func buttonAction(sender: UIButton!){
        startConnection()
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSError
        // throwing an error on the line below (can't figure out where the error message is)
        print("received data")
        let jsonResult: NSArray = (try! NSJSONSerialization.JSONObjectWithData(self.jsonData, options: NSJSONReadingOptions.MutableContainers)) as! NSArray
        
        for record in jsonResult {
            if let player = record as? NSDictionary {
                let decodedData = NSData(base64EncodedString: (player["image"]) as! String, options: NSDataBase64DecodingOptions(rawValue: 0))
                let dataItem = DataItem(indexes: String(player["uid"]!), image: decodedData!)
                self.data[1].append(dataItem)
            }
        }
        Players.reloadData()
        loadingSign.stopAnimating()
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print(error)
    }
    
    
    
    // MARK : UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[collectionView.tag].count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ColorCell
        
        let dataItem = data[collectionView.tag][indexPath.item]
        cell.imageView.image = UIImage(data: dataItem.image)
//        cell.label.text = String(indexPath.item) + "\n\n" + dataItem.indexes
//        cell.backgroundColor = dataItem.colour
        cell.imageView.layer.borderWidth = 3
        cell.imageView.layer.masksToBounds = false
        cell.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        cell.imageView.layer.cornerRadius = 27
        cell.imageView.clipsToBounds = true

        
        cell.hidden = false
        cell.contentView.frame = cell.bounds
        cell.contentView.autoresizingMask = [.FlexibleLeftMargin,
            .FlexibleWidth,
            .FlexibleRightMargin,
            .FlexibleTopMargin,
            .FlexibleHeight,
            .FlexibleBottomMargin]
        
/*        if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
            
            if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                
                if draggingPathOfCellBeingDragged.item == indexPath.item {
                    
                    cell.hidden = true
                    
                }
            }
        }
*/
        
        return cell
    }
    
    // MARK : KDDragAndDropCollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, dataItemForIndexPath indexPath: NSIndexPath) -> AnyObject {
        return data[collectionView.tag][indexPath.item]
    }
    func collectionView(collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: NSIndexPath) -> Void {
        
        if let di = dataItem as? DataItem {
            data[collectionView.tag].insert(di, atIndex: indexPath.item)
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
    
    
}

