
//
//  ViewController.swift
//  TableSoccerPoc
//
//  Created by Michel Georgy on 10/09/15.
//  Copyright (c) 2015 4eyes GmbH. All rights reserved.
//

import UIKit
import SWRevealViewController

class DataItem : Equatable {
    
    var indexes : String!
    var image : Data!
    init(indexes : String, image : Data) {
        self.indexes = indexes
        print(indexes);
        self.image = image
    }
}

func ==(lhs: DataItem, rhs: DataItem) -> Bool {
    return lhs.indexes == rhs.indexes
}

class PlayerViewController: UIViewController, KDDragAndDropCollectionViewDataSource, NSURLConnectionDelegate {
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var TeamRed: UICollectionView!
    @IBOutlet weak var TeamBlue: UICollectionView!
    @IBOutlet weak var Players: UICollectionView!
    
    @IBOutlet weak var fieldView: UIView!
    
    @IBOutlet weak var redDefence: UIView!
    @IBOutlet weak var redAttack: UIView!
    @IBOutlet weak var blueDefence: UIView!
    @IBOutlet weak var blueAttack: UIView!
    
    @IBOutlet weak var loadingSign: UIActivityIndicatorView!
    
    var data : [[DataItem]] = [[DataItem]]()
    
    var jsonData = NSMutableData()
    
    var dragAndDropManager : KDDragAndDropManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true);
        
        if revealViewController() != nil {
            menuButton.addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside);
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        // initialize data array to store the data for the 3 containers (available players, red team, blue team)
        for i in 0...2 {
            let items = [DataItem]()
            self.data.append(items)
        }
        
        self.dragAndDropManager = KDDragAndDropManager(canvas: self.view, collectionViews: [TeamRed, Players, TeamBlue]);
        
        
        self.redDefence.layer.borderColor = UIColor.white.cgColor
        self.redDefence.layer.cornerRadius = 33.5
        self.redDefence.layer.borderWidth = 3
        
        self.redAttack.layer.borderColor = UIColor.white.cgColor
        self.redAttack.layer.cornerRadius = 33.5
        self.redAttack.layer.borderWidth = 3
        
        self.blueDefence.layer.borderColor = UIColor.white.cgColor
        self.blueDefence.layer.cornerRadius = 33.5
        self.blueDefence.layer.borderWidth = 3
        
        self.blueAttack.layer.borderColor = UIColor.white.cgColor
        self.blueAttack.layer.cornerRadius = 33.5
        self.blueAttack.layer.borderWidth = 3

    }
    
    override func viewDidLayoutSubviews() {
        self.drawField();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//                startConnection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startConnection()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "newgame"){
            let gameViewController = segue.destination as! GameViewController
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
    
    @IBAction func showStatistics(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: Constants.Url.Statistic)!)
    }
    
    func drawField(){
        // Build a triangular path
        let path = UIBezierPath();
        
        path.move(to: CGPoint(x: fieldView.frame.size.width, y: 0));
        path.addLine(to: CGPoint(x: 0, y: fieldView.frame.size.height));
        path.addLine(to: CGPoint(x: fieldView.frame.size.width, y: fieldView.frame.size.height));
        path.addLine(to: CGPoint(x: fieldView.frame.size.width, y: 0));
        
        // Create a CAShapeLayer with this triangular path
        // Same size as the original imageView
        let mask = CAShapeLayer();
        mask.frame = fieldView.bounds;
        mask.path = path.cgPath;
        
        // Mask the imageView's layer with this shape
        fieldView.layer.mask = mask;
    }
    
    func startConnection(){
        let url: URL = URL(string: Constants.Url.Player)!
        let request: URLRequest = URLRequest(url: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
    }
    
    func connection(_ connection: NSURLConnection!, didReceiveData jsonData: Data!){
        self.jsonData.append(jsonData)
    }
    
    func buttonAction(_ sender: UIButton!){
        startConnection()
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        var err: NSError
        // throwing an error on the line below (can't figure out where the error message is)
        print("received data")
        let jsonResult: NSArray = (try! JSONSerialization.jsonObject(with: self.jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSArray
        
        for record in jsonResult {
            if let player = record as? NSDictionary {
                let decodedData = Data(base64Encoded: (player["image"]) as! String, options: NSData.Base64DecodingOptions(rawValue: 0))
                let dataItem = DataItem(indexes: String(describing: player["uid"]!), image: decodedData!)
                self.data[1].append(dataItem)
            }
        }
        Players.reloadData()
        loadingSign.stopAnimating()
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print(error)
    }
    
    
    
    // MARK : UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[collectionView.tag].count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ColorCell
        
        let dataItem = data[collectionView.tag][(indexPath as NSIndexPath).item]
        cell.imageView.image = UIImage(data: dataItem.image)
        cell.imageView.layer.borderWidth = 3
        cell.imageView.layer.masksToBounds = false
        cell.imageView.layer.borderColor = UIColor.white.cgColor
        cell.imageView.layer.cornerRadius = 27
        cell.imageView.clipsToBounds = true

        
        cell.isHidden = false
        cell.contentView.frame = cell.bounds
        cell.contentView.autoresizingMask = [.flexibleLeftMargin,
            .flexibleWidth,
            .flexibleRightMargin,
            .flexibleTopMargin,
            .flexibleHeight,
            .flexibleBottomMargin]
        
        return cell
    }
    
    // MARK : KDDragAndDropCollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {
        return data[collectionView.tag][(indexPath as NSIndexPath).item]
    }
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: IndexPath) -> Void {
        
        if let di = dataItem as? DataItem {
            data[collectionView.tag].insert(di, at: (indexPath as NSIndexPath).item)
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath : IndexPath) -> Void {
        data[collectionView.tag].remove(at: (indexPath as NSIndexPath).item)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to : IndexPath) -> Void {
        
        let fromDataItem: DataItem = data[collectionView.tag][(from as NSIndexPath).item]
        data[collectionView.tag].remove(at: (from as NSIndexPath).item)
        data[collectionView.tag].insert(fromDataItem, at: (to as NSIndexPath).item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: to) as! ColorCell
        cell.isHidden = false
        collectionView.reloadData()

    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
        if let candidate : DataItem = dataItem as? DataItem {
            
            for item : DataItem in data[collectionView.tag] {
                if candidate  == item {
                    
                    let position = data[collectionView.tag].index(of: item)! // ! if we are inside the condition we are guaranteed a position
                    let indexPath = IndexPath(item: position, section: 0)
                    return indexPath
                }
            }
        }
        
        return nil
        
    }
    
    
}

