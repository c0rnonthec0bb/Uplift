//
//  Dialog.swift
//  Uplift
//
//  Created by Adam Cobb on 11/10/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class DialogCallback{
    var execute:()->Bool
    
    init(execute:@escaping ()->Bool){
        self.execute = execute
    }
}

class Dialog {
    static var dialog:UIView!
    static var shown = false;
    static weak var context:ViewController!
    
    static func showDialog(title:String, contentView:UIView, negativeText:String?, positiveText:String?, positiveCallback:DialogCallback?){
    
    context = ViewController.context
    
    context.layout_dialog.removeAllViews();
        context.layout_dialog.isHiddenX = false
    
    dialog = UIView()
        LayoutParams.setWidth(view: dialog, width: 300)
        LayoutParams.centerParentVertical(subview: dialog)
        LayoutParams.centerParentHorizontal(subview: dialog)
        context.layout_dialog.addSubview(dialog);
        NSLayoutConstraint(item: dialog, attribute: .height, relatedBy: .lessThanOrEqual, toItem: context.layout_dialog, attribute: .height, multiplier: 1, constant: -24).isActive = true
    
    TouchController.setUniversalOnTouchListener(dialog, allowSpreadMovement: false);
    
    let titleView = UILabelX()
        LayoutParams.alignParentLeftRight(subview: titleView)
        LayoutParams.alignParentTop(subview: titleView)
        LayoutParams.setHeight(view: titleView, height: 48)
        titleView.setInsets(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0))
    titleView.text = title
    titleView.textColor = Color.WHITE
        titleView.font = ViewController.typefaceM(20)
        titleView.backgroundImage = Drawables.theme_gradient()
        titleView.roundCorners(corners: [.topLeft, .topRight], radius: 6)
    dialog.addSubview(titleView);
    
    let contentScroll = UIScrollViewX()
    LayoutParams.alignParentLeftRight(subview: contentScroll)
        LayoutParams.stackVertical(topView: titleView, bottomView: contentScroll)
        contentScroll.backgroundColor = Color.dialog_back
        dialog.addSubview(contentScroll);
        NSLayoutConstraint(item: dialog, attribute: .bottom, relatedBy: .equal, toItem: contentScroll, attribute: .bottom, multiplier: 1, constant: 42).isActive = true
    
    TouchController.setUniversalOnTouchListener(contentScroll, allowSpreadMovement: false);
    
        LayoutParams.alignParentScrollVertical(subview: contentView)
    contentScroll.addSubview(contentView)
        
        let hc = NSLayoutConstraint(item: contentScroll, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1, constant: 0)
        hc.priority = 1
        hc.isActive = true
    
    let shadowTop = ContentCreator.shadow(top: true, alpha: 0.3);
        LayoutParams.alignParentLeftRight(subview: shadowTop)
        LayoutParams.setHeight(view: shadowTop, height: 3)
        LayoutParams.alignTop(view1: shadowTop, view2: contentScroll)
    dialog.addSubview(shadowTop);
        
    let shadowBottom = ContentCreator.shadow(top: false, alpha: 0.3);
        LayoutParams.alignParentLeftRight(subview: shadowBottom)
        LayoutParams.setHeight(view: shadowBottom, height: 3)
        LayoutParams.alignBottom(view1: shadowBottom, view2: contentScroll)
        dialog.addSubview(shadowBottom);
    
    let bottom = UIView()
        LayoutParams.alignParentLeftRight(subview: bottom)
        LayoutParams.setHeight(view: bottom, height: 42)
        LayoutParams.alignParentBottom(subview: bottom)
        bottom.backgroundColor = .white
        
        bottom.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 6)
    dialog.addSubview(bottom);
    
    let positiveView = UILabelX()
        positiveView.setInsets(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
    ContentCreator.setUpBoldThemeStyle(positiveView, size: 20, italics: true);
    
    if let positiveText = positiveText {
        LayoutParams.alignParentRight(subview: positiveView)
        LayoutParams.alignParentTopBottom(subview: positiveView)
    bottom.addSubview(positiveView);
    positiveView.text = positiveText
    }
    
    let negativeView = UILabelX()
    negativeView.setInsets(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        negativeView.textColor = Color.halfBlack
        negativeView.font = ViewController.typefaceMI(20)
        
        if let negativeText = negativeText{
            LayoutParams.alignParentTopBottom(subview: negativeView)
            if positiveText == nil{
                LayoutParams.alignParentRight(subview: negativeView)
            }else{
                LayoutParams.stackHorizontal(leftView: negativeView, rightView: positiveView)
            }
            bottom.addSubview(negativeView)
            negativeView.text = negativeText
        }
        
        if positiveText == nil{
            negativeView.roundCorners(corners: .bottomRight, radius: 6)
        }else{
            positiveView.roundCorners(corners: .bottomRight, radius: 6)
        }
        
        TouchController.setUniversalOnTouchListener(positiveView, allowSpreadMovement: false, onOffCallback: OnOffCallback(on: {
            positiveView.backgroundColor = Color.view_touch
        }, off:{
            positiveView.backgroundColor = .clear
        }), clickCallback: ClickCallback(execute: {
            if positiveCallback!.execute(){
                animateHide();
            }
        }))
        
        TouchController.setUniversalOnTouchListener(negativeView, allowSpreadMovement: false, onOffCallback: OnOffCallback(on: {
            negativeView.backgroundColor = Color.view_touch
        }, off:{
            negativeView.backgroundColor = .clear
        }), clickCallback: ClickCallback(execute: {
                animateHide();
        }))
        
        context.layout_dialog.touchListener = TouchListener(touchDown: {_ in
            Dialog.animateHide()
            return true
        }, touchMove: {_ in return true}, touchUpCancel: {_ in return true})
    
    animateShow();
    }
    
    static func animateShow(){
    
    context.layout_dialog.alpha = 0
    context.layout_dialog.isHiddenX = false
    dialog.scaleX = 0.8
        dialog.scaleY = 0.8
    dialog.translationY = 64
    
    context.clearAllFocus()
    
    shown = true;
    
        let _ = context.layout_dialog.animate().alpha(1).setDuration(200).setInterpolator(.decelerate).setListener(AnimatorListener(onAnimationEnd: {
        }));
    let _ = dialog.animate().scaleX(1).scaleY(1).translationY(0).setDuration(300).setInterpolator(.overshoot);
}

static func animateHide(){
    
    context.clearAllFocus()
    
    if(!shown){
        return;
    }
    
    shown = false;
    
    let _ = context.layout_dialog.animate().alpha(0).setStartDelay(100).setDuration(100).setInterpolator(.accelerate).setListener(AnimatorListener(onAnimationEnd: {
        context.layout_dialog.isHiddenX = true
    }))
    
    let _ = dialog.animate().scaleX(0.8).scaleY(0.8).translationY(64).setDuration(200).setInterpolator(.accelerate);
}

    static func showTextDialog(title:String, text:String, negativeText:String?, positiveText:String?, positiveCallback:DialogCallback?){
    
        context = ViewController.context
    
    let textView = UILabelX()
    textView.textAlignment = .center
        textView.setInsets(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
    textView.text = text
    textView.textColor = Color.BLACK
        textView.alpha = 0.5
        textView.font = ViewController.typefaceR(14)
    
    showDialog(title: title, contentView: textView, negativeText: negativeText, positiveText: positiveText, positiveCallback: positiveCallback);
}
}
