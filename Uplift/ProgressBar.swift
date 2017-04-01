//
//  ProgressBar.swift
//  Uplift
//
//  Created by Adam Cobb on 12/29/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class ProgressBar : UIActivityIndicatorView{
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero)
        }else{
            super.init(coder: coder!)
        }
    }
    
    convenience init(){
        self.init(coder: nil)
        self.color = Color.theme
        self.startAnimating()
    }
}
