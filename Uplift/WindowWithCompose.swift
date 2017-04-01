//
//  WindowWithCompose.swift
//  Uplift
//
//  Created by Adam Cobb on 12/29/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class WindowWithCompose : WindowBase{
    override init(){
    super.init();
    
    if(WindowBase.topShownWindow() != nil && WindowBase.topShownWindow() is WindowWithCompose) {
    WindowBase.instances.remove(element: self)
    return;
    }
    
    buildTitle("Uplift The World");
    buildCompose();
    buildFrame();
    showFrame();
    }
    
    var composeView:ComposeView!
    
    func buildCompose(){
    
    let layout = UIView()
    
    let scroll = UIScrollViewX()
        LayoutParams.alignParentLeftRight(subview: scroll)
        LayoutParams.alignParentTopBottom(subview: scroll, marginTop: 0, marginBottom: 44)
    scroll.backgroundColor = Color.main_background
        
        composeView = ComposeView(id: nil);
        LayoutParams.alignParentScrollVertical(subview: composeView)
    scroll.addSubview(composeView);
    layout.addSubview(scroll);
        
    TouchController.setUniversalOnTouchListener(scroll, allowSpreadMovement: true);
        
    let shadow = ContentCreator.shadow(top: false, alpha: 0.2);
        LayoutParams.setHeight(view: shadow, height: 6)
        LayoutParams.alignParentBottom(subview: shadow, margin: 44)
    layout.addSubview(shadow);
    
    layout.addSubview(composeView.bottomView);
        
        scroll.scrollChangedListeners.append({
            if (scroll.contentOffset.y == self.composeView.height - scroll.height) {
                shadow.isHiddenX = true
            } else {
                shadow.isHiddenX = false
            }
        })
    
        composeView.newContentCallback = UpdateCallback(execute: {
            scroll.smoothScrollY(self.composeView.measuredSize.height, durationInMillis: 400, delay: 200)
        })
    
    content = layout;
    }
    
    override func hideFrame(send:Bool){
        super.hideFrame(send: send);
        Async.run(2000, SyncInterface(runTask: {
            self.composeView.contentLayout.removeAllViews();
            for callback in self.composeView.preSendCallback {
                callback.onDestroy();
            }
        }))
    }
}
