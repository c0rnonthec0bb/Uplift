//
//  WindowBase.swift
//  Uplift
//
//  Created by Adam Cobb on 9/25/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class WindowBase:NSObject{
    
    static weak var context:ViewController!
    weak var context:ViewController! = WindowBase.context
    static var layout_windows:UIView!
    let layout_windows:UIView! = WindowBase.layout_windows
    static var instances:[WindowBase] = []
    var shadow:UIView!
    var topShadow:UIView!
    var frame:UIView!
    var titleView:BasicViewGroup!
    var titleTextView:ScrollingTextView!
    var expandView:BasicViewGroup?
    var expandToggle:UIImageViewX!
    var expandShown = false;
    var expandShownTemp = false;
    var content:UIView!
    var shown = false;
    var shownTime:Int64 = 0;
    var stillInterceptingTouch = false;
    
    static var topH:CGFloat!
    var topH:CGFloat = WindowBase.topH
    static var expandH:CGFloat!
    var expandH:CGFloat = WindowBase.expandH
    
    static func topShownWindow()->WindowBase?{
        for i in stride(from: WindowBase.instances.count - 1, through: 0, by: -1){
            let instance = WindowBase.instances[i];
            if instance.shown{
                return instance;
            }
        }
        return nil;
    }
    
    override init(){
        super.init()
        initFrame();
        WindowBase.instances.append(self);
    }
    
    func showFrame(){
    
    layout_windows.isHidden = false
    
    frame.isHidden = false
    context.layout_all.backgroundColor = Color.theme_0_625
    shadow.isHidden = false
    
        var duration:Int64 = 300;
    if(!shown) {
    frame.translationY = context.screenHeight
    shown = true;
    }else{
        duration = 250 * Int64(abs(frame.translationY / context.screenHeight))
        duration += 200 * Int64(abs(frame.translationX / context.screenWidth)) + 200; //split up for Swift's dumb compiler
    }
    
    let _ = context.layout_main.animate().scaleX(0.95).scaleY(0.95).setStartDelay(0).setDuration(200).setInterpolator(.accelerate).setListener(nil);
        for instance in WindowBase.instances{
            if(instance !== self){
    let _ = instance.frame.animate().scaleX(0.95).scaleY(0.95).setStartDelay(0).setDuration(200).setInterpolator(.accelerate).setListener(nil);
            }
        }
    
    let _ = shadow.animate().alpha(0.3).setDuration(duration).setInterpolator(.linear);
        let _ = frame.animate().translationY(0).translationX(0).setDuration(duration).setStartDelay(0).setInterpolator(.decelerate).setListener(AnimatorListener(onAnimationEnd: {
            self.context.layout_main.isHidden = true
            self.context.layout_all.backgroundColor = .clear
            self.shadow.isHidden = true
            
            for instance in WindowBase.instances{
                if(instance !== self){
                    instance.frame.isHidden = true
                }
            }
            
            if (self.expandView != nil){
                Async.run(400, SyncInterface(runTask: {
                    if (self.expandShownTemp){
                        self.hideExpand();
                }
                }))
            }
        }))
    
    shownTime = Int64(Date().timeIntervalSince1970) * 1000 + duration + 100;
}

    func hideFrame(send:Bool){
    if(shown) {
        
        frame.animate().cancel();
        
        shadow.isHidden = false
        
        context.clearAllFocus();
        
        var duration:Int64 = 300, delay:Int64 = 0;
        var targetTranslationY:CGFloat = 0, targetTranslationX:CGFloat = 0;
        var interpolator:Interpolator = .linear
        if(send){
            targetTranslationY = -context.screenHeight;
            interpolator = .anticipate
            duration = 600;
            delay = 300;
        }else{
            
            if(frame.translationY < 0){
                targetTranslationY = -context.screenHeight;
                duration = Int64(300 * (1 + frame.translationY / context.screenHeight));
            }else if(frame.translationY > 0){
                targetTranslationY = context.screenHeight;
                duration = Int64(300 * (1 - frame.translationY / context.screenHeight));
            }else if(frame.translationX < 0){
                targetTranslationX = -context.screenWidth;
                duration = Int64(300 * (1 + frame.translationX / context.screenWidth));
            }else if(frame.translationX > 0){
                targetTranslationX = context.screenWidth;
                duration = Int64(300 * (1 - frame.translationX / context.screenWidth));
            }else{
                interpolator = .accelerate
                targetTranslationX = context.screenWidth;
            }
        }
        
        let _ = shadow.animate().alpha(0).setDuration(duration).setInterpolator(.linear);
        let _ = frame.animate().translationY(targetTranslationY).translationX(targetTranslationX).setDuration(duration).setStartDelay(0).setInterpolator(interpolator).setListener(nil);
        
        var nextFrame = context.layout_main!
        
        for i in stride(from: WindowBase.instances.count - 1, through: 0, by: -1){
            let instance = WindowBase.instances[i];
            if instance !== self && instance.shown{
                nextFrame = instance.frame;
                break;
            }
        }
        
        context.layout_all.backgroundColor = Color.theme_0_625
        
        let moreDelay = duration >= 300;
        
        Async.run(delay, SyncInterface(runTask: {
            nextFrame.isHidden = false
            let _ = nextFrame.animate().scaleX(1).scaleY(1).setStartDelay(moreDelay ? 200 : 0).setDuration(400).setInterpolator(.bounce).setListener(AnimatorListener(onAnimationEnd: {
                self.shown = false;
                
                self.context.layout_all.backgroundColor = .clear
                
                if (!self.stillInterceptingTouch) {
                    self.frame.removeFromSuperview()
                }
                
                self.shadow.removeFromSuperview()
                
                WindowBase.instances.remove(element: self);
                
                if(WindowBase.instances.count == 0 && !self.stillInterceptingTouch){
                    self.layout_windows.isHidden = true
                }
                
                let _ = self.context.view.fixUserInteraction() //iOS only
            }))
        }))
    }
}

func initFrame(){
    shadow = UIView()
    LayoutParams.alignParentLeftRight(subview: shadow)
    LayoutParams.alignParentTopBottom(subview: shadow)
    shadow.backgroundColor = Color.BLACK
    shadow.alpha = 0
    
    layout_windows.addSubview(shadow);
    
    frame = UIView()
    frame.isHidden = true
    LayoutParams.alignParentLeftRight(subview: frame)
    LayoutParams.alignParentTopBottom(subview: frame)
    layout_windows.addSubview(frame);
    
    TouchController.setUniversalOnTouchListener(frame, allowSpreadMovement: false);
}

func buildFrame(){
    frame.removeAllViews();
    
    if !(self is WindowWithWebView){
    LayoutParams.alignParentLeftRight(subview: content)
    LayoutParams.alignParentTopBottom(subview: content, marginTop: topH, marginBottom: 0)
    }
    frame.addSubview(content);
    
    topShadow = ContentCreator.shadow(top: true, alpha: 0.15);
    LayoutParams.alignParentLeftRight(subview: topShadow)
    LayoutParams.setHeight(view: topShadow, height: 2)
    LayoutParams.alignParentTop(subview: topShadow, margin: topH)
    frame.addSubview(topShadow);
    
    if let expandView = expandView{
        LayoutParams.alignParentLeftRight(subview: expandView)
        LayoutParams.setHeight(view: expandView, height: expandH)
        LayoutParams.alignParentTop(subview: expandView, margin: topH)
        frame.addSubview(expandView);
        
        hideExpand();
    }
    
    LayoutParams.alignParentLeftRight(subview: titleView)
    LayoutParams.setHeight(view: titleView, height: topH)
    LayoutParams.alignParentTop(subview: titleView)
    frame.addSubview(titleView);
}

    func buildTitle(_ titleText:String){
    titleView = BasicViewGroup();
        
    titleView.backgroundImage = Drawables.theme_gradient()
    
    let back = UIImageViewX()
        back.image = #imageLiteral(resourceName: "back")
        back.setInsets(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 10))
    titleView.addSubview(back);
    Layout.exact(back, width: topH, height: topH);
        
        TouchController.setUniversalOnTouchListener(back, allowSpreadMovement: false, onOffCallback: OnOffCallback(on:{
            back.backgroundColor = Color.theme_0_75
        }, off:{
            back.backgroundColor = .clear
        }), clickCallback: ClickCallback(execute: {
            self.hideFrame(send: false)
        }))
    
    titleTextView = ScrollingTextView();
    titleTextView.text = titleText
    titleTextView.label.textColor = Color.WHITE
        titleTextView.label.font = ViewController.typefaceB(20)
    titleView.addSubview(titleTextView);
        
    let titleLeft = topH + 4
    
    if(expandView == nil) {
        Layout.exact(titleTextView, l: titleLeft, t: 0, width: context.screenWidth - titleLeft - 4, height: topH);
    }else{
        Layout.exact(titleTextView, l: titleLeft, t: 0, width: context.screenWidth - titleLeft * 2, height: topH);
        
        let toggleBack = UIView()
        titleView.addSubview(toggleBack);
        Layout.exactLeft(toggleBack, r: context.screenWidth, t: 0, width: topH, height: topH);
        
        expandToggle = UIImageViewX()
        expandToggle.image = #imageLiteral(resourceName: "expand")
        expandToggle.setInsets(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        titleView.addSubview(expandToggle);
        Layout.exactLeft(expandToggle, r: context.screenWidth, t: 0, width: topH, height: topH);
        
        TouchController.setUniversalOnTouchListener(expandToggle, allowSpreadMovement: false, onOffCallback: OnOffCallback(on:{
            toggleBack.backgroundColor = Color.theme_0_75
        }, off:{
            toggleBack.backgroundColor = .clear
        }), clickCallback: ClickCallback(execute: {
            if self.expandShown{
                self.hideExpand()
            }else{
                self.showExpand(permanent: true)
            }
        }))
    }
}

func buildExpand(){ //must be before buildTitle()
    expandView = BasicViewGroup()
    expandView!.backgroundColor = Color.title_background
    expandView!.translationY = -expandH
    
    let highlightBottom = UIView()
    highlightBottom.backgroundColor = Color.title_highlight
    expandView!.addSubview(highlightBottom);
    Layout.exactUp(highlightBottom, l: 0, b: expandH, width: context.screenWidth, height: 1);
}

    func showExpand(permanent:Bool){
    expandShown = true;
    
        if(!permanent){
            expandShownTemp = true;
        }
    
    expandView!.animate().cancel();
    let _ = expandToggle.animate().rotation(180).setDuration(permanent ? 300 : 100).setInterpolator(.accelerateDecelerate);
    let _ = expandView!.animate().translationY(0).setDuration(permanent ? 300 : 100).setInterpolator(.decelerate).setListener(nil);
    let _ = topShadow.animate().translationY(expandH).setDuration(permanent ? 300 : 100).setInterpolator(.decelerate);
    
    for subview in expandView!.subviews{
        subview.isHidden = false
    }
}

func hideExpand(){
    expandShown = false;
    expandShownTemp = false;
    
    let _ = expandToggle.animate().rotation(0).setDuration(300).setInterpolator(.accelerateDecelerate);
    let _ = topShadow.animate().translationY(0).setDuration(300).setInterpolator(.accelerate);
    let _ = expandView!.animate().translationY(-expandH).setDuration(300).setInterpolator(.accelerate).setListener(AnimatorListener(onAnimationEnd: {
        for subview in self.expandView!.subviews{
            if(subview.y + subview.height <= self.expandH){
                subview.isHidden = true
            }
        }
    }))
}

    func scrollActionOnFalseMove(v:UIView, touches:[UITouch], deltay:CGFloat)->Bool{
        return false;
    }
    
        func scrollActionOnFalseUpCancel(v:UIView, touches:[UITouch], deltay:CGFloat)->Bool{
            return false;
        }

}
