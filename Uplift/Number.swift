//
//  Number.swift
//  Uplift
//
//  Created by Adam Cobb on 11/2/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

extension Int{
    func sign()->Int{
        return self == 0 ? 0 : self > 0 ? 1 : -1
    }
}

extension CGFloat{
    func sign()->CGFloat{
        return self == 0 ? 0 : self > 0 ? 1 : -1
    }
}
