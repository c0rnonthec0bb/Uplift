//
//  EnhancedWebView.swift
//  Uplift
//
//  Created by Adam Cobb on 11/3/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import WebKit

class EnhancedWebView: WKWebView {
    
    required init(coder:NSCoder?){
        if coder == nil{
            super.init(frame: .zero, configuration: WKWebViewConfiguration())
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init(){
        self.init(coder: nil)
        self.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    public func acceptableDeltaX(_ deltax:CGFloat)->Bool{
        if(deltax > 0){
            return scrollView.contentOffset.x <= 0;
        }
    
    return scrollView.contentOffset.x >= scrollView.contentSize.width - self.width;
    }
    
    public func acceptableDeltaY(_ deltay:CGFloat)->Bool{
        if(deltay > 0){
    return scrollView.contentOffset.y <= 0;
        }
    
    return scrollView.contentOffset.y >= scrollView.contentSize.height - self.height;
    }
    
    var onProgressChanged:(Double)->Void = {_ in}
    
    func setOnProgressChanged(onProgressChanged:@escaping (Double)->Void){
        self.onProgressChanged = onProgressChanged
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        onProgressChanged(self.estimatedProgress)
    }
}
