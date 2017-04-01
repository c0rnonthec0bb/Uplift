//
//  Layout.swift
//  Uplift
//
//  Created by Adam Cobb on 10/28/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

/**
 * Created by Adam on 8/26/16.
 */
class Layout {
    static func exact(_ view:UIView, l:CGFloat, t:CGFloat, width:CGFloat, height:CGFloat){
        for constraint in view.superview!.constraints{
            if constraint.firstItem === view && constraint.relation == .equal{
                constraint.isActive = false
            }
        }
        
        view.measuredOrigin = CGPoint(x: l, y: t)
        
        Measure.set(view, width: width, height: height)
        LayoutParams.alignParentTop(subview: view, margin: t)
        LayoutParams.alignParentLeft(subview: view, margin: l)
    }
    
    static func exact(_ view:UIView, width:CGFloat, height:CGFloat){
        exact(view, l: 0, t: 0, width: width, height: height);
    }
    
    static func exactLeft(_ view:UIView, r:CGFloat, t:CGFloat, width:CGFloat, height:CGFloat){
        exact(view, l: r - width, t: t, width: width, height: height);
    }
    
    static func exactUp(_ view:UIView, l:CGFloat, b:CGFloat, width:CGFloat, height:CGFloat){
    exact(view, l: l, t: b - height, width: width, height: height);
    }
    
    static func exactLeftUp(_ view:UIView, r:CGFloat, b:CGFloat, width:CGFloat, height:CGFloat){
    exact(view, l: r - width, t: b - height, width: width, height: height);
    }
    
    static func wrap(_ view:UIView, l:CGFloat, t:CGFloat){
    let dimens = Measure.wrap(view);
    exact(view, l: l, t: t, width: dimens.width, height: dimens.height)
    }
    
    static func wrapLeft(_ view:UIView, r:CGFloat, t:CGFloat){
        let dimens = Measure.wrap(view);
        exact(view, l: r - dimens.width, t: t, width: dimens.width, height: dimens.height)
    }
    
    static func wrapUp(_ view:UIView, l:CGFloat, b:CGFloat){
        let dimens = Measure.wrap(view);
        exact(view, l: l, t: b - dimens.height, width: dimens.width, height: dimens.height)
    }
    
    static func wrapLeftUp(_ view:UIView, r:CGFloat, b:CGFloat){
        let dimens = Measure.wrap(view);
        exact(view, l: r - dimens.width, t: b - dimens.height, width: dimens.width, height: dimens.height)
    }
    
    static func wrapCenterW(_ view:UIView, c:CGFloat, t:CGFloat){
        let dimens = Measure.wrap(view);
        exact(view, l: c - dimens.width / 2, t: t, width: dimens.width, height: dimens.height)
    }
    
    static func wrapCenterH(_ view:UIView, l:CGFloat, c:CGFloat){
        let dimens = Measure.wrap(view);
        exact(view, l: l, t: c - dimens.height / 2, width: dimens.width, height: dimens.height)
    }
    
    static func wrapCenter(_ view:UIView, ch:CGFloat, cv:CGFloat){
        let dimens = Measure.wrap(view);
        exact(view, l: ch - dimens.width / 2, t: cv - dimens.height / 2, width: dimens.width, height: dimens.height)
    }
    
    static func wrapH(_ view:UIView, l:CGFloat, t:CGFloat, width:CGFloat){
        exact(view, l: l, t: t, width: width, height: Measure.wrapH(view, width: width))
    }
    
    static func wrapHLeft(_ view:UIView, r:CGFloat, t:CGFloat, width:CGFloat){
        exact(view, l: r - width, t: t, width: width, height: Measure.wrapH(view, width: width))
    }
    
    static func wrapHUp(_ view:UIView, l:CGFloat, b:CGFloat, width:CGFloat){
        let height = Measure.wrapH(view, width: width)
        exact(view, l: l, t: b - height, width: width, height: height)
    }
    
    static func wrapHLeftUp(_ view:UIView, r:CGFloat, b:CGFloat, width:CGFloat){
        let height = Measure.wrapH(view, width: width)
        exact(view, l: r - width, t: b - height, width: width, height: height)
    }
    
    static func wrapHCenterH(_ view:UIView, l:CGFloat, c:CGFloat, width:CGFloat){
        let height = Measure.wrapH(view, width: width)
        exact(view, l: l, t: c - height / 2, width: width, height: height)
    }
    
    static func wrapW(_ view:UIView, l:CGFloat, t:CGFloat, height:CGFloat){
        exact(view, l: l, t: t, width: Measure.wrapW(view, height: height), height: height)
    }
    
    static func wrapWLeft(_ view:UIView, r:CGFloat, t:CGFloat, height:CGFloat){
        let width = Measure.wrapW(view, height: height)
        exact(view, l: r - width, t: t, width: width, height: height)
    }
    
    static func wrapWUp(_ view:UIView, l:CGFloat, b:CGFloat, height:CGFloat){
        exact(view, l: l, t: b - height, width: Measure.wrapW(view, height: height), height: height)
    }
    
    static func wrapWLeftUp(_ view:UIView, r:CGFloat, b:CGFloat, height:CGFloat){
        let width = Measure.wrapW(view, height: height)
        exact(view, l: r - width, t: b - height, width: width, height: height)
    }
    
    static func wrapWCenterW(_ view:UIView, c:CGFloat, t:CGFloat, height:CGFloat){
        let width = Measure.wrapW(view, height: height)
        exact(view, l: c - width / 2, t: t, width: width, height: height)
    }
    
    static func same(_ view:UIView){
    }
}
