//
//  KDDragAndDropManager.swift
//  KDDragAndDropCollectionViews
//
//  Created by Michael Michailidis on 10/04/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//

import UIKit

@objc protocol KDDraggable {
    func canDragAtPoint(_ point : CGPoint) -> Bool
    func representationImageAtPoint(_ point : CGPoint) -> UIView?
    func dataItemAtPoint(_ point : CGPoint) -> AnyObject?
    func dragDataItem(_ item : AnyObject) -> Void
    @objc optional func startDraggingAtPoint(_ point : CGPoint) -> Void
    @objc optional func stopDragging() -> Void
}


@objc protocol KDDroppable {
    func canDropAtRect(_ rect : CGRect) -> Bool
    func willMoveItem(_ item : AnyObject, inRect rect : CGRect) -> Void
    func didMoveItem(_ item : AnyObject, inRect rect : CGRect) -> Void
    func didMoveOutItem(_ item : AnyObject) -> Void
    func dropDataItem(_ item : AnyObject, atRect : CGRect) -> Void
}

class KDDragAndDropManager: NSObject, UIGestureRecognizerDelegate {
    
    fileprivate var canvas : UIView = UIView()
    fileprivate var views : [UIView] = []
    fileprivate var longPressGestureRecogniser = UILongPressGestureRecognizer()
    
    
    struct Bundle {
        var offset : CGPoint = CGPoint.zero
        var sourceDraggableView : UIView
        var overDroppableView : UIView?
        var representationImageView : UIView
        var dataItem : AnyObject
    }
    var bundle : Bundle?
    
    init(canvas : UIView, collectionViews : [UIView]) {
        
        super.init()
        
        self.canvas = canvas
        
        self.longPressGestureRecogniser.delegate = self
        self.longPressGestureRecogniser.minimumPressDuration = 0.015
        self.longPressGestureRecogniser.addTarget(self, action: #selector(KDDragAndDropManager.updateForLongPress(_:)))
        
        self.canvas.addGestureRecognizer(self.longPressGestureRecogniser)
        self.views = collectionViews
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        for view in self.views.filter({ v -> Bool in v is KDDraggable})  {
            
                let draggable = view as! KDDraggable
                
                let touchPointInView = touch.location(in: view)
                
                if draggable.canDragAtPoint(touchPointInView) == true {
                    
                    if let representation = draggable.representationImageAtPoint(touchPointInView) {
                        
                        representation.frame = self.canvas.convert(representation.frame, from: view)
                        
                        representation.alpha = 0.7
                        
                        let pointOnCanvas = touch.location(in: self.canvas)
                        
                        let offset = CGPoint(x: pointOnCanvas.x - representation.frame.origin.x, y: pointOnCanvas.y - representation.frame.origin.y)
                        
                        if let dataItem : AnyObject = draggable.dataItemAtPoint(touchPointInView) {
                            
                            self.bundle = Bundle(
                                offset: offset,
                                sourceDraggableView: view,
                                overDroppableView : view is KDDroppable ? view : nil,
                                representationImageView: representation,
                                dataItem : dataItem
                            )
                            
                            return true
                    
                        } // if let dataIte...
                
                    } // if let representation = dragg...
                   
           
            } // if draggable.canDragAtP...
            
        } // for view in self.views.fil...
        
        return false
        
    }
    
    
    
    
    func updateForLongPress(_ recogniser : UILongPressGestureRecognizer) -> Void {
        
        if let bundl = self.bundle {
            
            let pointOnCanvas = recogniser.location(in: recogniser.view)
            let sourceDraggable : KDDraggable = bundl.sourceDraggableView as! KDDraggable
            let pointOnSourceDraggable = recogniser.location(in: bundl.sourceDraggableView)
            
            switch recogniser.state {
                
                
            case .began :
                self.canvas.addSubview(bundl.representationImageView)
                sourceDraggable.startDraggingAtPoint?(pointOnSourceDraggable)
                
            case .changed :
                
                // Update the frame of the representation image
                var repImgFrame = bundl.representationImageView.frame
                repImgFrame.origin = CGPoint(x: pointOnCanvas.x - bundl.offset.x, y: pointOnCanvas.y - bundl.offset.y);
                bundl.representationImageView.frame = repImgFrame
                
                var overlappingArea : CGFloat = 0.0
                
                var mainOverView : UIView?
                
                for view in self.views.filter({ v -> Bool in v is KDDroppable}) {
                 
                    let viewFrameOnCanvas = self.convertRectToCanvas(view.frame, fromView: view)
                    
                    // Figure out which collection view is most of the image over
                    let intersectionNew = bundl.representationImageView.frame.intersection(viewFrameOnCanvas).size
                    
                    
                    if (intersectionNew.width * intersectionNew.height) > overlappingArea {
                        
                        overlappingArea = intersectionNew.width * intersectionNew.width
                        
                        mainOverView = view
                    }

                    
                }
                
                
                if let droppable = mainOverView as? KDDroppable {
                    
                    let rect = self.canvas.convert(bundl.representationImageView.frame, to: mainOverView)
                    
                    if bundl.sourceDraggableView != mainOverView {
                        
                        droppable.willMoveItem(bundl.dataItem, inRect: rect)
                        
                        
                    }
                    
                    self.bundle!.overDroppableView = mainOverView
                    
                    droppable.didMoveItem(bundl.dataItem, inRect: rect)
                    
                }
                
               
            case .ended :
                
                if bundl.sourceDraggableView != bundl.overDroppableView {
                    
                    if let droppable = bundl.overDroppableView as? KDDroppable {
                        
                        sourceDraggable.dragDataItem(bundl.dataItem)
                        
                        let rect = self.canvas.convert(bundl.representationImageView.frame, to: bundl.overDroppableView)
                        
                        droppable.dropDataItem(bundl.dataItem, atRect: rect)
                        
                    }
                }
                
                
                bundl.representationImageView.removeFromSuperview()
                sourceDraggable.stopDragging?()
                
            default:
                break
                
            }
            
            
        } // if let bundl = self.bundle ...
        
        
        
    }
    
    // MARK: Helper Methods 
    func convertRectToCanvas(_ rect : CGRect, fromView view : UIView) -> CGRect {
        
        var r : CGRect = rect
        
        var v = view
        
        while v != self.canvas {
            
            if let sv = v.superview {
                
                r.origin.x += sv.frame.origin.x
                r.origin.y += sv.frame.origin.y
                
                v = sv
                
                continue
            }
            break
        }
        
        return r
    }
   
}
