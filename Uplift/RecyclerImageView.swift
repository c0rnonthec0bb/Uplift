//
//  RecyclerImageView.swift
//  Uplift
//
//  Created by Adam Cobb on 10/15/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class RecyclerImageView: UIImageView {
    convenience init(_ image:Data?, _ bitmapDimens:[Int]){
        self.init(image, bitmapDimens[0], bitmapDimens[1])
    }
    
    init(_ raw:Data?, _ bitmapWidth:Int, _ bitmapHeight:Int){
        super.init(image: raw == nil ? nil : UIImage(data: raw!))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setViewDimens(width:CGFloat, height:CGFloat){
        LayoutParams.setWidth(view: self, width: width)
        LayoutParams.setHeight(view: self, height: height)
    }
    
    static var checkingUndrawn = false
    
    static let checkUndrawn = AsyncInterface(runTask: {
        
    })
}
