//
//  ContentCreator2.swift
//  Uplift
//
//  Created by Adam Cobb on 11/10/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class ContentCreator2{
    static func setUpSides(inView: UIView){ //added for swift cause its so simple
        let leftSide = UIView()
        leftSide.backgroundColor = Color.side_color
        inView.addSubview(leftSide)
        LayoutParams.setWidth(view: leftSide, width: 1)
        LayoutParams.alignParentLeft(subview: leftSide)
        LayoutParams.alignParentTopBottom(subview: leftSide)
        
        let rightSide = UIView()
        rightSide.backgroundColor = Color.side_color
        inView.addSubview(rightSide)
        LayoutParams.setWidth(view: rightSide, width: 1)
        LayoutParams.alignParentRight(subview: rightSide)
        LayoutParams.alignParentTopBottom(subview: rightSide)
    }
}
