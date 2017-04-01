//
//  SortSwitch.swift
//  Uplift
//
//  Created by Adam Cobb on 9/5/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit


class SortSwitch : UIView {
    
    weak var context:ViewController! = ViewController.context
    
    static var H:CGFloat!
    var H:CGFloat! = SortSwitch.H
    
    var sortCallback:SortCallback!
    
    var byUplifts = false;
    
    var choice1_front:UILabelX!
    var choice2_front:UILabelX!
    var switchBack:UIView!, switchFront:UIImageView!
    
    var fileName:String!
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero)
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init(comments:Bool, pageName:String, callback:SortCallback){ //pageName is "view1", etc or postId for comments
        self.init(coder: nil)
        
        fileName = pageName + "_sorted";
        
        sortCallback = callback;
        
        byUplifts = Files.readBoolean(fileName, false);
        
        LayoutParams.alignParentLeftRight(subview: self)
        LayoutParams.setHeight(view: self, height: H)
        self.backgroundColor = Color.WHITE
        
        let layout = UIView()
        LayoutParams.alignParentTopBottom(subview: layout)
        LayoutParams.centerParentHorizontal(subview: layout)
        self.addSubview(layout)
        
        let text = UILabelX()
        LayoutParams.alignParentTopBottom(subview: text)
        LayoutParams.alignParentLeft(subview: text)
        if(comments){
            text.text = "Sort Comments by "
        }else{
            text.text = "Sort Posts by "
        }
        text.textColor = Color.BLACK
        text.font = ViewController.typefaceM(17)
        layout.addSubview(text);
        
        let choice1 = UIView()
        LayoutParams.alignParentTopBottom(subview: choice1)
        LayoutParams.stackHorizontal(leftView: text, rightView: choice1)
        layout.addSubview(choice1);
        
        let choice1_back = UILabelX()
        LayoutParams.alignParentTopBottom(subview: choice1_back)
        LayoutParams.alignParentLeftRight(subview: choice1_back)
        choice1_back.textAlignment = .center
        choice1_back.numberOfLines = 2
        choice1_back.setInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        choice1_back.text = "Most\nRecent"
        choice1_back.font = ViewController.typefaceM(14)
        choice1_back.textColor = Color.halfBlack
        choice1.addSubview(choice1_back);
        
        choice1_front = UILabelX()
        LayoutParams.alignParentTopBottom(subview: choice1_front)
        LayoutParams.alignParentLeft(subview: choice1_front)
        choice1_front.textAlignment = .center
        choice1_front.numberOfLines = 2
        choice1_front.setInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        choice1_front.text = "Most\nRecent"
        ContentCreator.setUpBoldThemeStyle(choice1_front, size: 14, italics: false);
        choice1.addSubview(choice1_front);
        
        let switchLayout = UIView()
        LayoutParams.setWidth(view: switchLayout, width: 48)
        LayoutParams.setHeight(view: switchLayout, height: 24)
        LayoutParams.centerParentVertical(subview: switchLayout)
        LayoutParams.stackHorizontal(leftView: choice1, rightView: switchLayout)
        layout.addSubview(switchLayout);
        
        switchBack = UIView()
        LayoutParams.setWidth(view: switchBack, width: 40)
        LayoutParams.setHeight(view: switchBack, height: 16)
        LayoutParams.setEqualConstraint(view1: switchBack, attribute1: .left, view2: switchLayout, attribute2: .left, margin: 4)
        LayoutParams.setEqualConstraint(view1: switchBack, attribute1: .top, view2: switchLayout, attribute2: .top, margin: 4)
        switchBack.backgroundColor = Color.theme
        switchBack.roundCorners(corners: .allCorners, radius: 8)
        switchLayout.addSubview(switchBack);
        
        switchFront = UIImageView()
        LayoutParams.setWidth(view: switchFront, width: 24)
        LayoutParams.setHeight(view: switchFront, height: 24)
        LayoutParams.alignParentTop(subview: switchFront)
        LayoutParams.alignParentLeft(subview: switchFront)
        
        switchFront.image = Drawables.switch_front()
        
        switchFront.touchListener = TouchListener(touchDown: { (v, touches) in
            self.on = true;
            self.Ox = touches.first!.location(in: self.context.view).x
            self.Oy = touches.first!.location(in: self.context.view).y
            self.Ot = v.translationX
            
            let _ = self.switchBack.animate().scaleY(0.75).setDuration(200).setInterpolator(.decelerate);
            
            return true
        }, touchMove: { (v, touches) in
            if(abs(touches.first!.location(in: self.context.view).x - self.Ox) > 5 || abs(touches.first!.location(in: self.context.view).y - self.Oy) > 5){
                self.on = false;
            }
            
            if(abs(touches.first!.location(in: self.context.view).x - self.Ox) > 15 && abs(touches.first!.location(in: self.context.view).y - self.Oy) < 15){
                //TODO v.getParent().requestDisallowInterceptTouchEvent(true);
            }
            
            var targetTranslation = self.Ot + touches.first!.location(in: self.context.view).x - self.Ox;
            
            if(targetTranslation < 0){
                targetTranslation = 0;
            }
            
            if(targetTranslation > v.width){
                targetTranslation = v.width;
            }
            
            v.translationX = targetTranslation
            
            return true
        }, touchUp: { (v, touches) in
            if(self.on){
                self.animateChoice(!self.byUplifts);
            }else {
                self.animateChoice(v.translationX > v.width / 2);
            }
            //TODO v.getParent().requestDisallowInterceptTouchEvent(false);
            let _ = self.switchBack.animate().scaleY(1).setDuration(200).setInterpolator(.decelerate);
            
            return true
        }, touchCancel: { (v, touches) in
            let _ = self.switchBack.animate().scaleY(1).setDuration(200).setInterpolator(.decelerate);
            self.animateChoice(self.byUplifts);
            return true
        })
        
        switchLayout.addSubview(switchFront);
        
        TouchController.setUniversalOnTouchListener(switchLayout, allowSpreadMovement: true, onOffCallback: OnOffCallback(on: {
            let _ = self.switchBack.animate().scaleY(0.75).setDuration(200).setInterpolator(.decelerate)
        }, off: {
            let _ = self.switchBack.animate().scaleY(1).setDuration(200).setInterpolator(.decelerate)
        }) , clickCallback: ClickCallback(execute: {
            self.animateChoice(!self.byUplifts)
        }))
        
        let choice2 = UIView()
        LayoutParams.alignParentTopBottom(subview: choice2)
        LayoutParams.stackHorizontal(leftView: switchLayout, rightView: choice2)
        LayoutParams.alignParentRight(subview: choice2)
        layout.addSubview(choice2);
        
        let choice2_back = UILabelX()
        LayoutParams.alignParentTopBottom(subview: choice2_back)
        LayoutParams.alignParentLeftRight(subview: choice2_back)
        choice2_back.textAlignment = .center
        choice2_back.numberOfLines = 2
        choice2_back.setInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        choice2_back.text = "Most\nUplifted"
        choice2_back.font = ViewController.typefaceM(14)
        choice2_back.textColor = Color.halfBlack
        choice2.addSubview(choice2_back);
        
        choice2_front = UILabelX()
        LayoutParams.alignParentTopBottom(subview: choice2_front)
        LayoutParams.alignParentLeft(subview: choice2_front)
        choice2_front.textAlignment = .center
        choice2_front.numberOfLines = 2
        choice2_front.setInsets(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        choice2_front.text = "Most\nUplifted"
        ContentCreator.setUpBoldThemeStyle(choice2_front, size: 14, italics: false);
        choice2.addSubview(choice2_front);
        
        TouchController.setUniversalOnTouchListener(choice1, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            self.animateChoice(false)
        }))
        
        TouchController.setUniversalOnTouchListener(choice2, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            self.animateChoice(true)
        }))
        
        ContentCreator2.setUpSides(inView: self)
        
        setChoice(byUplifts);
    }
    
    var on = false
    var Ox:CGFloat!, Oy:CGFloat!, Ot:CGFloat! //for switch listener
    
    func setChoice(_ sortByUplifts:Bool){
        
        if(byUplifts != sortByUplifts){
            
            byUplifts = sortByUplifts;
            sortCallback.execute(byUplifts);
        }
        
        Files.writeBoolean(fileName, sortByUplifts);
        
        choice1_front.animate().cancel();
        choice2_front.animate().cancel();
        switchFront.animate().cancel();
        if(byUplifts){
            choice1_front.alpha = 0
            choice2_front.alpha = 1
            switchFront.translationX = 24
        }else{
            choice1_front.alpha = 1
            choice2_front.alpha = 0
            switchFront.translationX = 0
        }
    }
    
    func animateChoice(_ sortByUplifts:Bool){
        
        if(byUplifts != sortByUplifts){
            byUplifts = sortByUplifts;
            sortCallback.execute(byUplifts);
            
            switchFront.scaleX = 0.75
            switchFront.scaleY = 0.75
        }
        
        Files.writeBoolean(fileName, sortByUplifts);
        
        let duration:Int64 = 200;
        let interpolator = Interpolator.decelerate
        
        switchFront.animate().cancel();
        let _ = switchFront.animate().scaleX(1).scaleY(1).setDuration(duration).setInterpolator(interpolator);
        
        if(byUplifts){
            let _ = choice1_front.animate().alpha(0).setDuration(duration).setInterpolator(interpolator);
            let _ = choice2_front.animate().alpha(1).setDuration(duration).setInterpolator(interpolator);
            let _ = switchFront.animate().translationX(24).setDuration(duration).setInterpolator(interpolator);
        }else{
            let _ = choice1_front.animate().alpha(1).setDuration(duration).setInterpolator(interpolator);
            let _ = choice2_front.animate().alpha(0).setDuration(duration).setInterpolator(interpolator);
            let _ = switchFront.animate().translationX(0).setDuration(duration).setInterpolator(interpolator);
        }
    }
}
