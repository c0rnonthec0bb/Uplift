//
//  Scroll.swift
//  Uplift
//
//  Created by Adam Cobb on 11/30/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class UIScrollViewX : UIScrollView, UIScrollViewDelegate{
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero)
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init (){
        self.init(coder: nil)
        self.delegate = self
        self.bounces = false
        self.delaysContentTouches = false
        self.panGestureRecognizer.cancelsTouchesInView = false
    }
    
    var canScroll = true
    
    override var contentOffset: CGPoint{
        get{
            return super.contentOffset
        }
        
        set(value){
            if canScroll{
                super.contentOffset = value
            }
        }
    }
    
    var scrollChangedListeners:[()->Void] = []
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        Async.run(SyncInterface(runTask: {
        for listener in self.scrollChangedListeners{
            listener()
        }
        }))
    }
    
    func scrollY(_ scroll:CGFloat){
        let scroll = max(0, min(contentSize.height - originalSize.height, scroll))
        setContentOffset(CGPoint(x: contentOffset.x, y:scroll), animated: false)
    }
    
    func smoothScrollY(_ scroll: CGFloat, durationInMillis:Int64, delay:Int64){
        UIView.animate(withDuration: TimeInterval(durationInMillis) / 1000, delay: TimeInterval(delay) / 1000, options: .curveEaseInOut, animations: {
            self.scrollY(scroll)
        }, completion: nil)
    }
}
