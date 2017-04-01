//
//  Measure.swift
//  Uplift
//
//  Created by Adam Cobb on 10/28/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class Measure{
    static func w(_ view:UIView)->CGFloat{
        return view.measuredSize.width
    }
    
    static func h(_ view:UIView)->CGFloat{
        return view.measuredSize.height
    }
    
    static func set(_ view:UIView, width:CGFloat, height:CGFloat){
        view.measuredSize = CGSize(width: width, height: height)
        LayoutParams.setWidth(view: view, width: width)
        LayoutParams.setHeight(view: view, height: height)
    }
    
    static func wrap(_ view:UIView)->CGSize{
        view.measuredSize = view.intrinsicContentSize
        return view.measuredSize
    }
    
    static func wrapH(_ view:UIView, width:CGFloat)->CGFloat{
        view.measuredSize = view.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return view.measuredSize.height
    }
    
    static func wrapW(_ view:UIView, height:CGFloat)->CGFloat{
        view.measuredSize = view.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: height))
        return view.measuredSize.width
    }
}
