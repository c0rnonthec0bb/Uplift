//
//  TouchController.swift
//  Uplift
//
//  Created by Adam Cobb on 10/30/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

public class TouchController {
    
    static weak var context:ViewController!
    static var boxDimen:CGFloat!
    
    static var dragMode = 0; //uninitialised: 0, within box: 1, vertical: 2, horizontal: 3, canceled: -1
    static var Ox:CGFloat = 0, Oy:CGFloat = 0, Os:CGFloat = 0
    static var dx:CGFloat = 0, dy:CGFloat!, deltax:CGFloat = 0, deltay:CGFloat = 0
    static var layoutNum = 0;
    static var x:[CGFloat] = [0, 0], y:[CGFloat] = [0, 0]
    
    static func setUniversalOnTouchListener(_ view:UIView, allowSpreadMovement:Bool){
        setUniversalOnTouchListener(view, allowSpreadMovement: allowSpreadMovement, clickCallback: ClickCallback(execute: {}))
    }
    
    static func setUniversalOnTouchListener(_ view:UIView, allowSpreadMovement:Bool, clickCallback:ClickCallback){
        
        setUniversalOnTouchListener(view, allowSpreadMovement: allowSpreadMovement, onOffCallback: OnOffCallback(on: {}, off: {}), clickCallback: clickCallback)
    }
    
    static func setUniversalOnTouchListener(_ view:UIView, allowSpreadMovement:Bool, whiteWhenOff:Bool, clickCallback:ClickCallback){
    setUniversalOnTouchListener(view, allowSpreadMovement: allowSpreadMovement, visibleView: view, whiteWhenOff: whiteWhenOff, clickCallback: clickCallback)
    }
    
    static func setUniversalOnTouchListener(_ view:UIView, allowSpreadMovement:Bool, visibleView:UIView, whiteWhenOff:Bool, clickCallback:ClickCallback){
        setUniversalOnTouchListener(view, allowSpreadMovement: allowSpreadMovement, onOffCallback: OnOffCallback(on: {
            if (whiteWhenOff) {
                visibleView.backgroundColor = Color.view_touchOpaque
            } else {
                visibleView.backgroundColor = Color.view_touch
            }
            }, off: {
                if (whiteWhenOff) {
                    visibleView.backgroundColor = Color.WHITE
                } else {
                    visibleView.backgroundColor = .clear
                }
        }), clickCallback: clickCallback)
    }
    
    static var onMainSpread = true
    static weak var topWindow:WindowBase!
    
    static func setUniversalOnTouchListener(_ view:UIView, allowSpreadMovement:Bool, onOffCallback:OnOffCallback, clickCallback:ClickCallback){
    
    onOffCallback.off();
        
        view.touchListener = TouchListener(touchDown: {(view, touches) in
            if ((view is EnhancedWebView || view is ScrollingTextView) && dragMode <= 1) {
                //TODO view.getParent().requestDisallowInterceptTouchEvent(true);
                //TODO let _ = view.touchDown(alreadyReturnedTrue: false, touches: touches)
            }
            
            initialize(view, touches.first!, onOffCallback);
            return !(view is UIScrollView);
            
            }, touchMove: {(view, touches) in
                
                if ((view is EnhancedWebView || view is ScrollingTextView) && dragMode <= 1) {
                    //TODO view.getParent().requestDisallowInterceptTouchEvent(true);
                    //TODO let _ = view.touchMove(alreadyReturnedTrue: false, touches: touches)
                }
                
                if (dragMode == 0) {
                    initialize(view, touches.first!, onOffCallback);
                }
                
                x[1] = x[0];
                y[1] = y[0];
                x[0] = touches.first!.location(in: nil).x
                y[0] = touches.first!.location(in: nil).y
                
                dx = x[0] - x[1];
                dy = y[0] - y[1];
                
                deltax = x[0] - Ox;
                deltay = y[0] - Oy;
                
                if (dragMode == -1) {
                    return true;
                }
                
                if (dragMode == -2) {
                    return false;
                }
                
                if (abs(deltay) < boxDimen && abs(deltax) < boxDimen * 1.5 && dragMode <= 1) {
                    return !(view is UIScrollView);
                } else if (dragMode == 1) {
                    
                    onOffCallback.off();
                    
                    if (!LogIn.isLoggedIn()) {
                        dragMode = -2;
                        return true;
                    }
                    
                    if (abs(deltay) >= boxDimen){
                        
                        if (!allowSpreadMovement) {
                            dragMode = -1;
                            return !(view is UIScrollView);
                        }
                        
                        if let enhancedWebView = view as? EnhancedWebView{
                            if !enhancedWebView.acceptableDeltaY(deltay){
                                dragMode = -1;
                                return true;
                            }
                        }
                        
                        //TODO view.getParent().requestDisallowInterceptTouchEvent(false);
                        
                        dragMode = 2;
                        
                        if (onMainSpread) {
                            context.layout_top.animate().cancel();
                        }
                    }else{
                        
                        if (!allowSpreadMovement && onMainSpread) {
                            dragMode = -1;
                            return true;
                        }
                        if let enhancedWebView = view as? EnhancedWebView{
                            if !enhancedWebView.acceptableDeltaX(deltax){
                                dragMode = -1;
                                return true;
                            }
                        }
                        
                        if let scrollingTextView = view as? ScrollingTextView{
                            if !scrollingTextView.acceptableDeltaX(deltax){
                                dragMode = -1;
                                return true;
                            }
                        }
                        
                        dragMode = 3;
                        
                        if (onMainSpread) {
                            let _ = context.layout_top.animate().translationY(0).setDuration(150).setInterpolator(Interpolator.decelerate);
                            context.setMainPaddings(context.layout_top.translationY / 2);
                            Async.run(50, SyncInterface(runTask: {
                                context.setMainPaddings(0);
                            }))
                        } else {
                            topWindow.frame.animate().cancel();
                            topWindow.shadow.isHidden = false
                            
                            context.layout_all.backgroundColor = Color.theme_0_625
                            
                            var nextFrame = context.layout_main!
                            
                            for i in stride(from: WindowBase.instances.count - 1, through: 0, by: -1){
                                let instance = WindowBase.instances[i]
                                if (instance !== topWindow && instance.shown) {
                                    nextFrame = instance.frame;
                                    break;
                                }
                            }
                            
                            nextFrame.isHidden = false
                        }
                        //TODO v.getParent().requestDisallowInterceptTouchEvent(true);
                        
                    }
                    
                    Ox = touches.first!.location(in: nil).x
                    Oy = touches.first!.location(in: nil).y
                    Os = context.view_scrolls[layoutNum].contentOffset.y
                    
                    if (onMainSpread && Os == 0 && context.refreshing[layoutNum]) {
                        Os = 1;
                    }
                    
                } else {
                    
                    if (onMainSpread) {
                        
                        if (context.getMenuRatio(CGFloat(context.currentModeRatio()) - deltax / context.screenWidth) == -1) {
                            deltax = 0;
                            dx = 0;
                        }
                        
                        if ((dragMode == 3 || view is UIScrollView || context.view_scrolls[layoutNum].height >= context.view_layouts[layoutNum].height) && LogIn.isLoggedIn()) {
                            return drag_move();
                        } else {
                            return false;
                        }
                    } else {
                        
                        if (!topWindow.shown || topWindow.stillInterceptingTouch) {
                            return true;
                        }
                        
                        if (dragMode == 3) {
                            
                            topWindow.frame.translationX = deltax
                            
                            if (abs(deltax) > context.screenWidth / 2) {
                                topWindow.hideFrame(send: false);
                                topWindow.stillInterceptingTouch = true;
                                //TODO v.getParent().requestDisallowInterceptTouchEvent(true);
                            }
                        } else {
                            return topWindow.scrollActionOnFalseMove(v: view, touches: touches, deltay: deltay) || dragMode != 2
                        }
                    }
                }
                return true;
            }, touchUpCancel: {(up, view, touches) in
                
                if up{
                    if ((view is EnhancedWebView || view is ScrollingTextView) && dragMode <= 1) {
                        //TODO view.getParent().requestDisallowInterceptTouchEvent(true);
                        //TODO let _ = view.touchUp(alreadyReturnedTrue: false, touches: touches)
                    }
                    
                    if (dragMode == 1) {
                        onOffCallback.off();
                        clickCallback.execute();
                        context.clearAllFocus();
                    }
                }else{
                    if ((view is EnhancedWebView || view is ScrollingTextView) && dragMode <= 1) {
                        //TODO view.getParent().requestDisallowInterceptTouchEvent(true);
                        //TODO let _ = view.touchCancel(alreadyReturnedTrue: false, touches: touches)
                    }
                }
                
                //TODO v.getParent().requestDisallowInterceptTouchEvent(false);
                
                if (!up || dragMode != 1){
                    onOffCallback.off();
                }
                
                Async.run(resetMode)
                
                if (dragMode == -1) {
                    return true;
                }
                
                if (dragMode == -2) {
                    return false;
                }
                
                if (!onMainSpread && topWindow.stillInterceptingTouch) {
                    topWindow.stillInterceptingTouch = false;
                    if (!topWindow.shown) {
                        topWindow.frame.removeFromSuperview()
                        if WindowBase.instances.count == 0{
                            WindowBase.layout_windows.isHidden = true
                        }
                    }
                    let _ = context.view.fixUserInteraction() //iOS only
                    return true;
                }
                
                if (onMainSpread) {
                    if ((dragMode == 3 || view is UIScrollView || context.view_scrolls[layoutNum].height >= context.view_layouts[layoutNum].height) && LogIn.isLoggedIn()) {
                        return drag_up(view);
                    } else {
                        return true;
                    }
                } else {
                    if (!topWindow.shown) {
                        return true;
                    }
                    
                    if (dragMode == 3) {
                        
                        if (deltax.sign() == (x[0] - x[1]).sign() && abs(deltax) > 48) {
                            topWindow.hideFrame(send: false);
                        } else {
                            topWindow.showFrame();
                        }
                    } else {
                        return topWindow.scrollActionOnFalseUpCancel(v: view, touches: touches, deltay: deltay) || dragMode != 2
                    }
                    
                }
                return true;
        })
    }
    
    static var resetMode = SyncInterface(runTask: {
        dragMode = 0;
    })
    
    static func initialize(_ v:UIView, _ touch:UITouch, _ onOffCallback:OnOffCallback){
    dragMode = 1;
    
    onMainSpread = WindowBase.topShownWindow() == nil;
    topWindow = WindowBase.topShownWindow();
    
    Ox = touch.location(in: nil).x
    Oy = touch.location(in: nil).y
    layoutNum = context.currentModeRatio();
    
    onOffCallback.on();
    
    if (LogIn.isLoggedIn() && onMainSpread && context.view_layouts[layoutNum].height < context.view_scrolls[layoutNum].height - context.view_scrolls[layoutNum].contentInset.top) {
        //TODO v.getParent().requestDisallowInterceptTouchEvent(true);
    }
    }
    
    static func drag_move()->Bool{
    
    switch (dragMode){
    case 2:
    
    if(deltay >= 0 && Os == 0){
    let refreshViewTrans = 30 * log(deltay / 30 + 1);
    context.view_scrolls[layoutNum].translationY = refreshViewTrans
    if(refreshViewTrans >= RefreshView.refreshH!){
    context.view_refreshes[layoutNum].setPoised();
    }else{
    context.view_refreshes[layoutNum].setDefault();
    }
    if(context.view_scrolls[layoutNum].contentOffset.y != 0) {
        context.view_scrolls[layoutNum].contentOffset = .zero
    }
    return true;
}else if (!context.refreshing[layoutNum]){
    context.view_scrolls[layoutNum].translationY = 0
}

if(context.view_scrolls[layoutNum].contentOffset.y == Os){
    return false;
}

    var targetTranslation:CGFloat!

if(dy < 0) {
    if (context.layout_top.translationY + dy > -context.menuH) {
        targetTranslation = context.layout_top.translationY + dy;
    }else {
        targetTranslation = -context.menuH;
    }
}else{
    if (context.layout_top.translationY + dy < 0){
        targetTranslation = context.layout_top.translationY + dy;
    }else{
        targetTranslation = 0;
    }
}

if(targetTranslation < -context.view_scrolls[layoutNum].contentOffset.y){
    targetTranslation = -context.view_scrolls[layoutNum].contentOffset.y;
}

if(context.view_layouts[layoutNum].height < context.screenHeight!){
    targetTranslation = 0;
}

context.layout_top.translationY = targetTranslation

context.setMainPaddings(targetTranslation);
return false;
case 3:
context.move_all(CGFloat(context.currentModeRatio()) - deltax / context.screenWidth);
break;
default:break;
}
return true;
}

    static func drag_up(_ view:UIView)->Bool{
    
    if(dragMode == 3){
        if(abs(deltax) > 48) {
            if (abs(dx) < 1) {
                context.setModeToRatio(round(CGFloat(context.currentModeRatio()) - deltax / context.screenWidth));
            } else {
                context.setModeToRatio(CGFloat(context.currentModeRatio()) - 0.5 * dx.sign() - 0.5 * deltax.sign());
            }
        }
        context.animate_all();
    }
    
    if(dragMode == 2 || (dragMode == 1 && view is UIScrollView)){
        var targetTranslation:CGFloat!
        
        if(context.view_scrolls[layoutNum].contentOffset.y < context.menuH){
            targetTranslation = 0;
        }else if(abs(dy) < 1){
            targetTranslation = context.menuH * round(context.layout_top.translationY / context.menuH);
        }else{
            targetTranslation = context.menuH * (-0.5 + 0.5 * dy.sign());
        }
        
        let _ = context.layout_top.animate().translationY(targetTranslation).setDuration(150).setInterpolator(Interpolator.decelerate)
        
        context.setMainPaddings(0);
        Async.run(50, SyncInterface(runTask: {
            context.setMainPaddings(targetTranslation)
        }))
        
        if(context.view_scrolls[layoutNum].translationY >= RefreshView.refreshH){
            Refresh.refreshPage(context.currentMode, context.currentSubmode[context.currentMode]);
        }else{
            let _ = context.view_scrolls[layoutNum].animate().translationY(0).setDuration(200).setInterpolator(Interpolator.decelerate);
            context.view_refreshes[layoutNum].setDefault();
        }
        
        dragMode = 0;
    }
    dragMode = 0;
    return !(view is UIScrollView);
}

    static func setImagePinchTouchListener(imageFrame:UIView, imageView:UIImageViewX, imageWidth:CGFloat, imageHeight:CGFloat, minScale:CGFloat, window:WindowBase, callback:ImagePinchCallback){
        
        //center of imageView to center of touch point, in image's unscaled vector space
        var cToC:[CGFloat] = [0, 0]; //each goes -1 to 1
        var startTrans:[CGFloat] = [0, 0]; //real values
        var scaleFactor:CGFloat = 1;
        var pointerCount = 0;
        
        var imageZoomDragMode = 0; //0 = default, 1 = vertical, 2 = horizontal
        
        var x:CGFloat = 0; //for dx only
        var y:CGFloat = 0;
        
        imageFrame.touchListener = TouchListener(touchDown: { (view, touches) in
            
            var view2:UIView? = view
            while view2 != nil{
                view2!.isUserInteractionEnabled = true
                view2!.isMultipleTouchEnabled = true
                view2 = view2!.superview
            }
            
            pointerCount = 0;
            imageZoomDragMode = 0;
            x = touches.first!.location(in: nil).x
            y = touches.first!.location(in: nil).y
            return true
            }, touchMove: { (view, touches) in
                if(window.stillInterceptingTouch){
                    return true;
                }
                
                dx = touches.first!.location(in: nil).x - x;
                x = touches.first!.location(in: nil).x
                dy = touches.first!.location(in: nil).y - y;
                y = touches.first!.location(in: nil).y
                
                var halfDimens = [Measure.w(imageView) / 2, Measure.h(imageView) / 2];
                var scale = imageView.scaleX
                
                var newCToC:[CGFloat] = [0, 0];
                let newPointerCount = touches.count
                
                switch (newPointerCount) {
                case 0:
                    break;
                case 1:
                    newCToC[0] = (x / halfDimens[0] - 1) / scale;
                    newCToC[1] = (y / halfDimens[1] - 1) / scale;
                    break;
                default:
                    if(pointerCount == newPointerCount) {
                        scale = scaleFactor * hypot(touches[1].location(in: view).x - touches[0].location(in: view).x, touches[1].location(in: view).y - touches[0].location(in: view).y)
                        scale = min(5, max(minScale, scale));
                    }
                    newCToC[0] = ((touches[1].location(in: view).x + touches[0].location(in: view).x) / 2 / halfDimens[0] - 1) / scale;
                    newCToC[1] = ((touches[1].location(in: view).y + touches[0].location(in: view).y) / 2 / halfDimens[1] - 1) / scale;
                    break;
                }
                
                if(newPointerCount != pointerCount){
                    startTrans[0] = imageView.translationX
                    startTrans[1] = imageView.translationY
                    pointerCount = newPointerCount;
                    cToC = newCToC;
                    if(pointerCount > 1) {
                        scaleFactor = imageView.scaleX / hypot(touches[1].location(in: view).x - touches[0].location(in: view).x, touches[1].location(in: view).y - touches[0].location(in: view).y)
                        let _ = window.frame.animate().translationY(0).translationX(0).setDuration(400).setInterpolator(Interpolator.decelerate);
                        let _ = callback.dragUp(0);
                    }
                    return true;
                }
                
                if(pointerCount < 1){
                    return true;
                }
                
                var newTransX = imageView.translationX
                var newTransY = imageView.translationY
                
                if(pointerCount > 0) {
                    newTransX = (newCToC[0] - cToC[0]) * halfDimens[0] * scale + startTrans[0];
                    newTransY = (newCToC[1] - cToC[1]) * halfDimens[1] * scale + startTrans[1];
                }
                
                if(scale == 1 && pointerCount == 1){
                    if(imageZoomDragMode == 1 || (imageZoomDragMode == 0 && abs(newTransY) > boxDimen)){
                        if(imageZoomDragMode == 0){
                            imageZoomDragMode = 1;
                            cToC[1] = newCToC[1];
                            newTransY = 0;
                        }
                        
                        window.shadow.isHidden = false
                        window.frame.translationY = newTransY
                        
                        context.layout_all.backgroundColor = Color.theme_0_625
                        
                        var nextFrame = context.layout_main!
                        
                        for i in stride(from: WindowBase.instances.count - 1, through: 0, by: -1){
                            let instance = WindowBase.instances[i]
                            if (instance !== window && instance.shown) {
                                nextFrame = instance.frame;
                                break;
                            }
                        }
                        
                        nextFrame.isHidden = false
                        
                        if (abs(window.frame.translationY) > context.screenHeight / 2) {
                            window.hideFrame(send: false);
                            window.stillInterceptingTouch = true;
                            //TODO v.getParent().requestDisallowInterceptTouchEvent(true);
                        }
                        return true;
                    }
                    
                    if(imageZoomDragMode == 2 || (imageZoomDragMode == 0 && abs(newTransX) > boxDimen)){
                        if(imageZoomDragMode == 0){
                            imageZoomDragMode = 2;
                            cToC[0] = newCToC[0];
                            newTransX = 0;
                        }
                        
                        if(window.frame.translationX == 0 && callback.dragX(newTransX)) {
                            return true;
                        }else{
                            
                            window.frame.animate().cancel();
                            window.shadow.isHidden = false
                            
                            context.layout_all.backgroundColor = Color.theme_0_625
                            
                            var nextFrame = context.layout_main!
                            
                            for i in stride(from: WindowBase.instances.count - 1, through: 0, by: -1){
                                let instance = WindowBase.instances[i]
                                if (instance !== window && instance.shown) {
                                    nextFrame = instance.frame;
                                    break;
                                }
                            }
                            
                            nextFrame.isHidden = false
                            
                            if(newTransX * window.frame.translationX < 0){
                                newTransX = 0;
                            }
                            
                            window.frame.translationX = newTransX
                            
                            if (abs(window.frame.translationX) > context.screenWidth / 2) {
                                window.hideFrame(send: false);
                                window.stillInterceptingTouch = true;
                                //TODO v.getParent().requestDisallowInterceptTouchEvent(true);
                            }
                        }
                        return true;
                    }
                }
                
                context.layout_all.backgroundColor = .clear
                context.layout_main.isHidden = true
                window.shadow.isHidden = true
                window.frame.translationY = 0
                
                var vMargin = (imageFrame.height - context.screenWidth * CGFloat(imageHeight) / CGFloat(imageWidth)) / 2;
                if (vMargin < 0) {
                    vMargin = 0;
                }
                
                var hMargin = (context.screenWidth - imageFrame.height * CGFloat(imageWidth) / CGFloat(imageHeight)) / 2;
                if (hMargin < 0) {
                    hMargin = 0;
                }
                
                if (scale * (imageView.height - vMargin * 2) < imageFrame.height) {
                    newTransY = 0;
                } else if (abs(newTransY) + vMargin * scale > ((imageView.height) * (scale - 1)) / 2) {
                    newTransY = newTransY.sign() * (((imageView.height) * (scale - 1)) / 2 - vMargin * scale);
                }
                
                if (imageView.scaleX * (imageView.width - hMargin * 2) < imageFrame.width) {
                    newTransX = 0;
                } else if (abs(newTransX) + hMargin * scale > ((context.screenWidth) * (scale - 1)) / 2) {
                    newTransX = newTransX.sign() * (((context.screenWidth) * (scale - 1)) / 2 - hMargin * scale);
                }
                
                imageView.translationX = newTransX
                imageView.translationY = newTransY
                imageView.scaleX = scale
                imageView.scaleY = scale
                return true
            }, touchUpCancel: { (up, view, touches) in
                if (window.stillInterceptingTouch) {
                    window.stillInterceptingTouch = false;
                    if (!window.shown) {
                        window.frame.removeFromSuperview()
                        if WindowBase.instances.count == 0{
                        WindowBase.layout_windows.isHidden = true
                        }
                    }
                    let _ = context.view.fixUserInteraction() //iOS only
                    return true;
                }
                
                if(!window.shown){
                    return true;
                }
                
                if(imageZoomDragMode == 1 || window.frame.translationX != 0 || !callback.dragUp(dx)) {
                    if (pointerCount <= 1 && abs(window.frame.translationY) > 48 && dy * window.frame.translationY.sign() > 1) {
                        window.hideFrame(send: false);
                    } else if (pointerCount <= 1 && abs(window.frame.translationX) > 48 && dx * window.frame.translationX.sign() > 1) {
                        window.hideFrame(send: false);
                    } else {
                        window.showFrame();
                    }
                }
                return true
        })
}
}
