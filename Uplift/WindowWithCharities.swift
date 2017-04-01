//
//  WindowWithCharities.swift
//  Uplift
//
//  Created by Adam Cobb on 12/24/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
import Parse

class WindowWithCharities : WindowBase{
    
    var scroll:UIScrollViewX!
    var layout:UIView!
    
    var bottomLayout:UIView!
    
    var currentShownIndex = -1;
    
    override convenience init(){ //convenience for no start
        self.init(startId: "");
    }
    
    init(startId:String){
        super.init();
        
        if(WindowBase.topShownWindow() != nil && WindowBase.topShownWindow() is WindowWithCharities) {
            WindowBase.instances.remove(element: self)
            return;
        }
        
        buildTitle("Charities by Name");
        buildCharities(startId);
        buildFrame();
        showFrame();
    }
    
    func buildCharities(_ startId:String){
        
        if(scroll == nil) {
            scroll = UIScrollViewX()
            scroll!.backgroundColor = Color.main_background
            self.content = scroll;
            TouchController.setUniversalOnTouchListener(scroll, allowSpreadMovement: true);
        }else{
            scroll!.removeAllViews();
        }
        
        layout = UIView()
        LayoutParams.alignParentScrollVertical(subview: layout)
        scroll.addSubview(layout);
        
        let spinner = ProgressBar()
        LayoutParams.setWidthHeight(view: spinner, width: 50, height: 50)
        LayoutParams.alignParentTopBottom(subview: spinner, marginTop: 12, marginBottom: 0)
        LayoutParams.centerParentHorizontal(subview: spinner)
        spinner.startAnimating()
        layout.addSubview(spinner);
        
        let query = PFQuery(className: "Charity");
        query.addAscendingOrder("name");
        
        Async.run(Async.PRIORITY_INTERNETSMALL, AsyncInterface(runTask: {
            do{
                let objects = try query.findObjects()
                try PFObject.pinAll(objects)
                Async.run(max(self.shownTime - Int64(Date().timeIntervalSince1970 * 1000), 0), SyncInterface(runTask: {
                    
                    if (!self.shown) {
                        return;
                    }
                    
                    self.scroll.removeAllViews();
                    
                    self.layout = UIView()
                    self.scroll.addSubview(self.layout);
                    LayoutParams.alignParentScrollVertical(subview: self.layout)
                    
                    var translationDueToStart:CGFloat = 0;
                    
                    for i in 0 ..< objects.count {
                        
                        let subviews = self.layout.subviews //since subviews is mutated
                        
                        let charityView = CharityView(charity: CharityObject(obj: objects[i]), isFullCard: true);
                        self.layout.addSubview(charityView);
                        LayoutParams.alignParentLeftRight(subview: charityView)
                        if (subviews.count > 0) {
                            LayoutParams.setEqualConstraint(view1: charityView, attribute1: .top, view2: subviews.last!, attribute2: .top, margin: 84)
                        }else{
                            LayoutParams.alignParentTop(subview: charityView)
                        }
                        
                        charityView.translationY = translationDueToStart
                        
                        if (objects[i].objectId == startId) {
                            self.currentShownIndex = i;
                            
                            self.layout.layoutSubviews() //iOS only
                            let measuredHeight = charityView.height
                            
                            translationDueToStart = measuredHeight - 84;
                            
                            let arg1 = 84 * CGFloat(i); //bc swift is terrible at solving equations
                            var arg2 = CGFloat(objects.count) * 84 + 8 + translationDueToStart
                            arg2 -= self.context.screenHeight - self.topH
                            let newScroll = min(arg1, arg2);
                            Async.run(SyncInterface(runTask: {
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.scroll.setContentOffset(CGPoint(x: 0, y: newScroll), animated: false)
                                })
                            }))
                        }
                        
                        TouchController.setUniversalOnTouchListener(charityView, allowSpreadMovement: true, visibleView: charityView.cover, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
                            self.scrollToCharity(charityView, i);
                        }))
                    }
                    
                    let subviews = self.layout.subviews //since subviews is mutated
                    
                    self.bottomLayout = UIView()
                    self.layout.addSubview(self.bottomLayout);
                    LayoutParams.alignParentLeftRight(subview: self.bottomLayout)
                    LayoutParams.setHeight(view: self.bottomLayout, height: 8 + translationDueToStart)
                    LayoutParams.setEqualConstraint(view1: self.bottomLayout, attribute1: .top, view2: subviews.last!, attribute2: .top, margin: 84)
                    LayoutParams.alignParentBottom(subview: self.bottomLayout)
                    self.bottomLayout.backgroundColor = Color.main_background
                    
                    self.bottomLayout.translationY = translationDueToStart
                }))
            }catch{
                Async.toast("Failed to load charities.", true)
            }
        }))
    }
    
    func scrollToCharity(_ view:CharityView, _ index:Int) {
        for i in 0 ..< layout.subviews.count {
            if (i <= index || currentShownIndex == index) {
                let _ = layout.subviews[i].animate().translationY(0).setDuration(500).setInterpolator(.accelerateDecelerate);
            } else {
                let _ = layout.subviews[i].animate().translationY(view.height - 84).setDuration(500).setInterpolator(.accelerateDecelerate);
            }
        }
        
        let newBottomHeight = (currentShownIndex == index) ? 8 : (8 + view.height - 84);
        currentShownIndex = (currentShownIndex == index) ? -1 : index;
        
        let setBottomFirst = newBottomHeight >= bottomLayout.height;
        
        if (setBottomFirst) {
            LayoutParams.setHeight(view: bottomLayout, height: newBottomHeight)
        }
        
        let newScroll = max(min(view.y, bottomLayout.y + newBottomHeight - scroll.height), 0);
        
        UIView.animate(withDuration: 0.5, animations: {
            self.scroll.setContentOffset(CGPoint(x: 0, y: newScroll), animated: false)
        }, completion: { finished in
            if (!setBottomFirst) {
                LayoutParams.setHeight(view: self.bottomLayout, height: newBottomHeight)
            }
        })
    }
}
