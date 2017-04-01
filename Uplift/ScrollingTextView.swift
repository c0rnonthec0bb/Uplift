//
//  ScrollingTextView.swift
//  Uplift
//
//  Created by Adam Cobb on 11/3/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class ScrollingTextView: UIScrollViewX {
    
    var label = UILabelX()
    
    var text:String{
        get{
            return label.text ?? ""
        }
        
        set (newVal){
            label.text = newVal
            layoutSubviews()
        }
    }
    
    required init(coder:NSCoder?){
        super.init(coder: coder)
    }
    
    convenience init(){
        self.init(coder: nil)
        showsHorizontalScrollIndicator = false
        label.numberOfLines = 1
        
        addSubview(label)
        LayoutParams.alignParentScrollHorizontal(subview: label)
        TouchController.setUniversalOnTouchListener(self, allowSpreadMovement: false);
        
        scrollChangedListeners.append({
            if let mask = self.layer.mask as? CAGradientLayer{
                if self.contentOffset.x > 0{
                    mask.colors![0] = UIColor.clear.cgColor
                }else{
                    mask.colors![0] = UIColor.white.cgColor
                }
                
                if self.contentOffset.x < self.label.intrinsicContentSize.width - self.width{
                    mask.colors![3] = UIColor.clear.cgColor
                }else{
                    mask.colors![3] = UIColor.white.cgColor
                }
                mask.frame.origin.x = self.contentOffset.x
                self.layer.mask = mask
            }
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let mask = CAGradientLayer()
        mask.frame = CGRect(origin: .zero, size: originalSize)
        mask.startPoint = CGPoint(x: 0, y: 0.5)
        mask.endPoint = CGPoint(x: 1, y: 0.5)
        mask.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        mask.locations = [0, 0.1, 0.9, 1]
        layer.mask = mask
        scrollChangedListeners.first!()
    }
    
    public func acceptableDeltaX(_ deltax:CGFloat)->Bool{
        if(deltax > 0){
            return contentOffset.x <= 0;
        }
        
        return contentOffset.x >= contentSize.width - width;
    }
}
