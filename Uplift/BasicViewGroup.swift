//
//  BasicViewGroup.swift
//  Uplift
//
//  Created by Adam Cobb on 10/14/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class BasicViewGroup: UIView {
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero)
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init(){
        self.init(coder: nil)
    }
    
    var callback:BasicOnLayoutCallback?
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let callback = callback{
            callback.execute()
        }
    }*/
}

class BasicOnLayoutCallback {
    var execute:()->Void
    init(execute:@escaping ()->Void){
        self.execute = execute
    }
}
