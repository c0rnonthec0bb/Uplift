//
//  Activity.swift
//  Uplift
//
//  Created by Adam Cobb on 12/31/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class UIViewControllerX : UIViewController{
    
    private var constraintsToActivateX:[(isReady:()->Bool, constraint:()->NSLayoutConstraint)] = []
    
    var constraintsToActivate:[(isReady:()->Bool, constraint:()->NSLayoutConstraint)]{
        get{
            return constraintsToActivateX
        }
        set(value){
            constraintsToActivateX = value
            view.setNeedsUpdateConstraints()
        }
    }
    
    override func updateViewConstraints() {
        for i in stride(from: constraintsToActivateX.count - 1, through: 0, by: -1){
            let item = constraintsToActivateX[i];
            if item.isReady(){
                item.constraint().isActive = true
                self.constraintsToActivateX.remove(at: i)
            }
        }
        super.updateViewConstraints()
    }
    
    var views = NSHashTable<UIView>(options: [.weakMemory])
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Async.run(SyncInterface(runTask: {
            self.stuffForEachView(self.view)
            let _ = self.view.fixUserInteraction()
            for item in ViewHelper.onDidLayoutSubviews{
                if item.key.window != nil{
                    item.value()
                }
            }
            self.freeViews()
        }))
    }
    
    func stuffForEachView(_ view:UIView){
        if !views.contains(view){
            views.add(view)
        }
        view.layer.bounds = view.bounds
        for subview in view.subviews{
            stuffForEachView(subview)
        }
    }
    
    func onStart(){
    }
    
    func onResume() {}
    
    func onPause(){
    }
    
    func onStop(){
        freeViews()
    }
    
    func freeViews(){
        let views = self.views.allObjects
        for view in views{
            
            if let login_view = LogIn.login_view{
                var superview = view.superview
                while superview != nil && superview != login_view{
                    superview = superview!.superview
                }
                if superview == login_view{
                    continue
                }
            }
            
            if view.window == nil{
                self.views.remove(view)
                ViewHelper.onDidLayoutSubviews.removeValue(forKey: view)
                objc_removeAssociatedObjects(view)
                if let scroll = view as? UIScrollViewX{
                    scroll.scrollChangedListeners.removeAll()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint!
    var keyboardShown = false
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            
            var duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
 
            let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt
            
            var options:UIViewAnimationOptions?
                
            if let curve = curve{
                options = UIViewAnimationOptions.init(rawValue: curve)
            }
            
            if duration == nil{
                duration = 0.3
            }
            
            if options == nil{
                options = UIViewAnimationOptions.curveEaseOut
            }
            
            if keyboardShown{
                duration = 0.1
            }
            
            bottomConstraint.constant = keyboardSize.height
            
            UIView.animate(withDuration: duration!, delay: 0, options: options!, animations: {
                self.view.layoutIfNeeded()
                
                if let firstResponder = self.view.currentFirstResponder(){
                    var view:UIView? = firstResponder
                    while(view != nil){
                        if let scrollview = view as? UIScrollView{
                            scrollview.scrollRectToVisible(firstResponder.superview!.convert(firstResponder.frame, from: scrollview.subviews.first!), animated: false)
                            return;
                        }
                        view = view!.superview
                    }
                }
            }, completion: nil)
            
            keyboardShown = true
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt
        
        var options:UIViewAnimationOptions?
        
        if let curve = curve{
            options = UIViewAnimationOptions.init(rawValue: curve)
        }
        
        if duration == nil{
            duration = 0.3
        }
        
        if options == nil{
            options = UIViewAnimationOptions.curveEaseIn
        }
        
        bottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration!, delay: 0, options: options!, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        keyboardShown = false
    }
    
    override func didReceiveMemoryWarning() {
        if PostOrCommentObject.mediaData.count + UserObject.profileData.count < 10{
            PostOrCommentObject.thumbsData.removeAll()
            UserObject.thumbData.removeAll()
            CharityObject.pictureData.removeAll()
        }
        PostOrCommentObject.mediaData.removeAll()
        UserObject.profileData.removeAll()
    }
}
