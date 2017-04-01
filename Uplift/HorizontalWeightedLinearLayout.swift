//
//  HorizontalWeightedLinearLayout.swift
//  Uplift
//
//  Created by Adam Cobb on 9/26/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class HorizontalWeightedLinearLayout: UIView {
    
    var weights:[UIView:CGFloat] = [:]
    var subviewConstraints:[NSLayoutConstraint] = []
    
    func addSubview(_ view: UIView, weight: CGFloat) {
        addSubview(view)
        weights[view] = weight
        LayoutParams.alignParentTop(subview: view)
    }
    
    override func layoutSubviews() {
        for constraint in subviewConstraints{
            constraint.isActive = false
        }
        subviewConstraints.removeAll()
        
        var totalWeight:CGFloat = 0
        for weight in weights{
            totalWeight += weight.value
        }
        
        var prevView:UIView = self
        for subview in subviews{
            let weightConstraint = NSLayoutConstraint(item: subview, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: weights[subview]! / totalWeight, constant: 0)
            weightConstraint.isActive = true
            subviewConstraints.append(weightConstraint)
            
            let linearConstraint = NSLayoutConstraint(item: subview, attribute: .left, relatedBy: .equal, toItem: prevView, attribute: prevView == self ? .left : .right, multiplier: 1, constant: prevView == self ? 0 : 2)
            linearConstraint.isActive = true
            subviewConstraints.append(linearConstraint)
            
            prevView = subview
        }
        super.layoutSubviews()
        
        var maxHeight:CGFloat = 0
        
        for subview in subviews{
            maxHeight = max(maxHeight, subview.height)
        }
        
        self.height = maxHeight
        LayoutParams.setHeight(view: self, height: maxHeight)
    }
    
    deinit {
        subviewConstraints.removeAll()
        weights.removeAll()
    }
}
