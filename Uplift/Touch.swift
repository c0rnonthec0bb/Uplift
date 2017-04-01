//
//  Touch.swift
//  Uplift
//
//  Created by Adam Cobb on 11/3/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//


import UIKit
import GoogleMobileAds
import WebKit

private var touchListenerKey: UInt8 = 0

class TouchListener {
    
    var touchDown:(UIView, [UITouch])->Bool
    var touchMove:(UIView, [UITouch])->Bool
    var touchUp:(UIView, [UITouch])->Bool
    var touchCancel:(UIView, [UITouch])->Bool
    
    convenience init(return value:Bool){
        self.init(touchDown: {_ in return value}, touchMove: {_ in return value}, touchUpCancel: {_ in return value})
    }
    
    init(touchDown:@escaping (UIView, [UITouch])->Bool, touchMove:@escaping(UIView, [UITouch])->Bool, touchUp:@escaping(UIView, [UITouch])->Bool, touchCancel:@escaping(UIView, [UITouch])->Bool){
        self.touchDown = touchDown
        self.touchMove = touchMove
        self.touchUp = touchUp
        self.touchCancel = touchCancel
    }
    
    init(touchDown:@escaping (UIView, [UITouch])->Bool, touchMove:@escaping(UIView, [UITouch])->Bool, touchUpCancel:@escaping(Bool, UIView, [UITouch])->Bool){
        self.touchDown = touchDown
        self.touchMove = touchMove
        self.touchUp = { (view, touches) in
            return touchUpCancel(true, view, touches)
        }
        self.touchCancel = {(view, touches) in
            return touchUpCancel(false, view, touches)
        }
    }
    
    static var disabledViews:[UIView] = []
    
    static var lastInterceptedTouchAndView:(touch:UITouch?, view:UIView?) = (nil, nil)
    
    static func submitTouchFunction(_ function:(UIView, [UITouch])->Bool, view: UIView, touches: [UITouch]){
        
        if lastInterceptedTouchAndView.touch != touches.first! || lastInterceptedTouchAndView.view == view{
            
            if view.getTouchEnabled(){
                if function(view, touches){
                    lastInterceptedTouchAndView = (touches.first!, view)
                }else{
                    lastInterceptedTouchAndView = (nil, nil)
                }
            }else{
                lastInterceptedTouchAndView = (nil, nil)
            }
        }
    }
}

extension UIView{
    
    internal func myHeiarchy()->[Int]{
        var reverseHeiarchy:[Int] = []
        var view:UIView = self
        while(view.superview != nil){
            var subNum = 0
            for sub in view.superview!.subviews{
                if sub == view{
                    reverseHeiarchy.append(subNum)
                }
                subNum += 1
            }
            view = view.superview!
        }
        return reverseHeiarchy.reversed()
    }
    
    func setTouchEnabled(_ enabled:Bool){
        if enabled{
            for i in stride(from: TouchListener.disabledViews.count - 1, through: 0, by: -1){
                if TouchListener.disabledViews[i] === self{
                    TouchListener.disabledViews.remove(at: i)
                }
            }
        }else{
            TouchListener.disabledViews.append(self)
        }
        let _ = ViewController.context.view.fixUserInteraction()
    }
    
    func getTouchEnabled()->Bool{
        return !TouchListener.disabledViews.contains(self)
    }
    
    var touchListener:TouchListener?{
        get{
            return objc_getAssociatedObject(self, &touchListenerKey) as? TouchListener
        }
        
        set(value){
            objc_setAssociatedObject(self, &touchListenerKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            let _ = ViewController.context.view.fixUserInteraction()
        }
    }
    
    func fixUserInteraction()->Bool{
        var touchEnabled = false
        if !isHidden && getTouchEnabled(){
            for subview in subviews{
                if subview.fixUserInteraction(){
                    touchEnabled = true
                }
            }
            if touchListener != nil{
                touchEnabled = true
            }
        }
        isUserInteractionEnabled = touchEnabled
        return touchEnabled
    }
    
    func touchesBeganX(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("touches began for view " + myHeiarchy().debugDescription)
        
        if self == ViewController.context.view{
            let _ = fixUserInteraction()
        }
        
        if let listener = touchListener{
        
        var touches = touches
        
        if let event = event{
            if let allTouches = event.allTouches{
                touches = allTouches
            }
        }

            TouchListener.submitTouchFunction(listener.touchDown, view: self, touches: Array(touches))
        }
    }
    
    func touchesMovedX(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let listener = touchListener{
        
        var touches = touches
        
        if let event = event{
            if let allTouches = event.allTouches{
                touches = allTouches
            }
        }
        
            TouchListener.submitTouchFunction(listener.touchMove, view: self, touches: Array(touches))
        }
    }
    
    func touchesEndedX(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let listener = touchListener{
        
        var touches = touches
        
        if let event = event{
            if let allTouches = event.allTouches{
                touches = allTouches
            }
        }
        
            TouchListener.submitTouchFunction(listener.touchUp, view: self, touches: Array(touches))
        }
    }
    
    func touchesCancelledX(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let listener = touchListener{
        
        var touches = touches
        
        if let event = event{
            if let allTouches = event.allTouches{
                touches = allTouches
            }
        }
        
            TouchListener.submitTouchFunction(listener.touchCancel, view: self, touches: Array(touches))
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesBeganX(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMovedX(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEndedX(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesCancelledX(touches, with: event)
        super.touchesCancelled(touches, with: event)
    }
}

extension UIScrollViewX{
    
    override func fixUserInteraction() -> Bool {
        for subview in subviews{
            let _ = subview.fixUserInteraction()
        }
        isUserInteractionEnabled = true
        return true
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesBeganX(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMovedX(touches, with: event)
        
        if TouchListener.lastInterceptedTouchAndView.view == nil{
            TouchListener.lastInterceptedTouchAndView = (touches.first!, self)
            canScroll = true
        }else{
            canScroll = false
            self.panGestureRecognizer.setTranslation(.zero, in: self)
        }
        
        super.touchesMoved(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEndedX(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesCancelledX(touches, with: event)
        super.touchesCancelled(touches, with: event)
    }
}

extension UITextView{
    
    override func fixUserInteraction() -> Bool {
        isUserInteractionEnabled = true
        return true
    }
}

extension UITextField{
    
    override func fixUserInteraction() -> Bool {
        isUserInteractionEnabled = true
        return true
    }
}

extension GADBannerView{
    
    override func fixUserInteraction() -> Bool {
        isUserInteractionEnabled = true
        return true
    }
}

extension WKWebView{
    override func fixUserInteraction() -> Bool {
        isUserInteractionEnabled = true
        return true
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesBeganX(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMovedX(touches, with: event)
        
        if TouchListener.lastInterceptedTouchAndView.view == nil{
            TouchListener.lastInterceptedTouchAndView = (touches.first!, self)
        }
        
        super.touchesMoved(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEndedX(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesCancelledX(touches, with: event)
        super.touchesCancelled(touches, with: event)
    }
}
