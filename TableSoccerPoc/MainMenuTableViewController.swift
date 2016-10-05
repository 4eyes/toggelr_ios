//
//  GameViewController.swift
//  Toggelr
//
//  Created by Michel Georgy on 10/04/16.
//  Copyright © 2016 4eyes GmbH. All rights reserved.
//

import UIKit

class MainMenuTableViewController : UITableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //cell.backgroundView = nil;
        //cell.backgroundColor = UIColor.red;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var segueIdentifier = "";
        let row = indexPath.row;
        
        switch(row){
            case 0:
                segueIdentifier = "newgame";
                break;
            case 1:
                segueIdentifier = "leaderboard";
                break;
            default:
                break;
        }
        
        if(segueIdentifier != ""){
            self.parent?.performSegue(withIdentifier: segueIdentifier, sender: self);
        }
    }
}
