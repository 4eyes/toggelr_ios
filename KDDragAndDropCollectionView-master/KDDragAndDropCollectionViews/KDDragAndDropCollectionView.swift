//
//  KDDragAndDropCollectionView.swift
//  KDDragAndDropCollectionViews
//
//  Created by Michael Michailidis on 10/04/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit



@objc protocol KDDragAndDropCollectionViewDataSource : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath?
    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to : IndexPath) -> Void
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: IndexPath) -> Void
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath: IndexPath) -> Void
    
}

class KDDragAndDropCollectionView: UICollectionView, KDDraggable, KDDroppable {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var draggingPathOfCellBeingDragged : IndexPath?
    
    var iDataSource : UICollectionViewDataSource?
    var iDelegate : UICollectionViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    
    }
    

    // MARK : KDDraggable
    func canDragAtPoint(_ point : CGPoint) -> Bool {
        return self.dataSource != nil && self.dataSource is KDDragAndDropCollectionViewDataSource && self.indexPathForItem(at: point) != nil
    }
    
    func representationImageAtPoint(_ point : CGPoint) -> UIView? {
        
        var imageView : UIView?
        
        if let indexPath = self.indexPathForItem(at: point) {
            
            if let cell = self.cellForItem(at: indexPath){
                imageView = cell.snapshotView(afterScreenUpdates: true)
            
                imageView?.frame = cell.frame
            }
        }
        
        return imageView
    }
    
    func dataItemAtPoint(_ point : CGPoint) -> AnyObject? {
        
        var dataItem : AnyObject?
        
        if let indexPath = self.indexPathForItem(at: point) {
            
            if let dragDropDS : KDDragAndDropCollectionViewDataSource = self.dataSource as? KDDragAndDropCollectionViewDataSource {
                
                dataItem = dragDropDS.collectionView(self, dataItemForIndexPath: indexPath)
                
            }
            
        }

        return dataItem
    }
    
    
    
    func startDraggingAtPoint(_ point : CGPoint) -> Void {
        
        self.draggingPathOfCellBeingDragged = self.indexPathForItem(at: point)
        
        self.reloadData()
        
    }
    
    func stopDragging() -> Void {
        
        if let idx = self.draggingPathOfCellBeingDragged {
            if let cell = self.cellForItem(at: idx) {
                cell.isHidden = false
            }
        }
        
        self.draggingPathOfCellBeingDragged = nil
        
        self.reloadData()
        
    }
    
    func dragDataItem(_ item : AnyObject) -> Void {
        
        if let dragDropDS = self.dataSource as? KDDragAndDropCollectionViewDataSource {
            
            if let existngIndexPath = dragDropDS.collectionView(self, indexPathForDataItem: item) {
                
                dragDropDS.collectionView(self, deleteDataItemAtIndexPath: existngIndexPath)
                
                
                self.deleteItems(at: [existngIndexPath])
                
            }
            
        }
        
    }
    
    // MARK : KDDroppable

    func canDropAtRect(_ rect : CGRect) -> Bool {
        return true
    }
    
    func indexPathForCellOverlappingRect( _ rect : CGRect) -> IndexPath? {
        var overlappingArea : CGFloat = 0.0
        
        var cellCandidate : UICollectionViewCell?
        
        for visible in self.visibleCells {
            
            let intersection = visible.frame.intersection(rect)
            
            if (intersection.width * intersection.height) > overlappingArea {
                
                overlappingArea = intersection.width * intersection.width
                
                cellCandidate = visible
            }
            
        }
        
        if let cellRetrieved = cellCandidate {
            
            return self.indexPath(for: cellRetrieved)
        }

        return nil
    }
    
    
    fileprivate var currentInRect : CGRect?
    func willMoveItem(_ item : AnyObject, inRect rect : CGRect) -> Void {
        
        let dragDropDS = self.dataSource as! KDDragAndDropCollectionViewDataSource // guaranteed to have a ds
        
        if let existingIndexPath = dragDropDS.collectionView(self, indexPathForDataItem: item) {
            return
        }
        
        if let indexPath = self.indexPathForCellOverlappingRect(rect) {
            
            dragDropDS.collectionView(self, insertDataItem: item, atIndexPath: indexPath)
            
            self.draggingPathOfCellBeingDragged = indexPath
            
            self.insertItems(at: [indexPath])
            
        } else {
            dragDropDS.collectionView(self, insertDataItem: item, atIndexPath: IndexPath(item: 0, section: 0))
            
            self.draggingPathOfCellBeingDragged = IndexPath(item: 0, section: 0)
            
            self.insertItems(at: [IndexPath(item: 0, section: 0)])
        }
        
        currentInRect = rect
        
    }
    
    var paging : Bool = false
    func checkForEdgesAndScroll(_ rect : CGRect) -> Void {
        
        if paging == true {
            return
        }
        
        let currentRect : CGRect = CGRect(x: self.contentOffset.x, y: self.contentOffset.y, width: self.bounds.size.width, height: self.bounds.size.height)
        var rectForNextScroll : CGRect = currentRect
        
        if (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .horizontal {
            
            let leftBoundary = CGRect(x: -30.0, y: 0.0, width: 30.0, height: self.frame.size.height)
            let rightBoundary = CGRect(x: self.frame.size.width, y: 0.0, width: 30.0, height: self.frame.size.height)
            
            if rect.intersects(leftBoundary) == true {
                rectForNextScroll.origin.x -= self.bounds.size.width
                if rectForNextScroll.origin.x < 0 {
                    rectForNextScroll.origin.x = 0
                }
            }
            else if rect.intersects(rightBoundary) == true {
                rectForNextScroll.origin.x += self.bounds.size.width
                if rectForNextScroll.origin.x > self.contentSize.width - self.bounds.size.width {
                    rectForNextScroll.origin.x = self.contentSize.width - self.bounds.size.width
                }
            }
            
        }
        else if (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .vertical {
            
            let topBoundary = CGRect(x: 0.0, y: -30.0, width: self.frame.size.width, height: 30.0)
            let bottomBoundary = CGRect(x: 0.0, y: self.frame.size.height, width: self.frame.size.width, height: 30.0)
            
            if rect.intersects(topBoundary) == true {
                
            }
            else if rect.intersects(bottomBoundary) == true {
                
            }
        }
        
        // check to see if a change in rectForNextScroll has been made
        if currentRect.equalTo(rectForNextScroll) == false {
            self.paging = true
            self.scrollRectToVisible(rectForNextScroll, animated: true)
            
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.paging = false
            }
            
        }
        
    }
    
    func didMoveItem(_ item : AnyObject, inRect rect : CGRect) -> Void {
        
        let dragDropDS = self.dataSource as! KDDragAndDropCollectionViewDataSource // guaranteed to have a ds
        
        if let existingIndexPath = dragDropDS.collectionView(self, indexPathForDataItem: item),
               let indexPath = self.indexPathForCellOverlappingRect(rect) {
   
                if (indexPath as NSIndexPath).item != (existingIndexPath as NSIndexPath).item {
                    
                    dragDropDS.collectionView(self, moveDataItemFromIndexPath: existingIndexPath, toIndexPath: indexPath)
                    
                    self.moveItem(at: existingIndexPath, to: indexPath)
                    
                    self.draggingPathOfCellBeingDragged = indexPath
                    
                }
        }
        
        // Check Paging
        
        var normalizedRect = rect
        normalizedRect.origin.x -= self.contentOffset.x
        normalizedRect.origin.y -= self.contentOffset.y
        
        currentInRect = normalizedRect
        
        
        self.checkForEdgesAndScroll(normalizedRect)
        
        self.reloadData()
    }
    
    func didMoveOutItem(_ item : AnyObject) -> Void {
        currentInRect = nil
    }
    func dropDataItem(_ item : AnyObject, atRect : CGRect) -> Void {
        
        self.draggingPathOfCellBeingDragged = nil
        
        currentInRect = nil
        
        self.reloadData()
        
    }
    
    
    
}
