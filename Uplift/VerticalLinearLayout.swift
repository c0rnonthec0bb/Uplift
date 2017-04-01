//
//  VerticalLinearLayout.swift
//  Uplift
//
//  Created by Adam Cobb on 9/26/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class VerticalLinearLayout: UIView {
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero)
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init(){
        self.init(coder: nil)
        setInsets(.zero)
    }
    
    func addSubview(_ view: UIView, marginTop:CGFloat) {
        marginTops[view] = marginTop
        super.addSubview(view)
    }
    
    var marginTops:[UIView:CGFloat] = [:]
    var subviewConstraints:[NSLayoutConstraint] = []
    
    func marginTop(for view:UIView)->CGFloat{
        if let margin = marginTops[view]{
            return margin
        }
        return 0
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        
        updateConstraintsX()
    }
    
    func updateConstraintsX(){
    
        if Async.isAsync(){
            
        }
        
        NSLayoutConstraint.deactivate(subviewConstraints)
        
        subviewConstraints.removeAll()
        
        var prevView:UIView = self
        for subview in subviews{
            let constraint = NSLayoutConstraint(item: subview, attribute: .top, relatedBy: .equal, toItem: prevView, attribute: prevView == self ? .topMargin : .bottom, multiplier: 1, constant: marginTop(for:subview))
            subviewConstraints.append(constraint)
            if !subview.isHiddenX{
                prevView = subview
            }
        }
        
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottomMargin, relatedBy: .equal, toItem: prevView, attribute: prevView == self ? .topMargin : .bottom, multiplier: 1, constant: 0)
        subviewConstraints.append(bottomConstraint)
        
        NSLayoutConstraint.activate(subviewConstraints)
    }
    
    override func subviewVisibilityChanged(){
        updateConstraintsX()
        setNeedsLayout()
    }
}
