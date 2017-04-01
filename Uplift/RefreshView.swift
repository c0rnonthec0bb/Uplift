//
//  RefreshView.swift
//  Uplift
//
//  Created by Adam Cobb on 9/5/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class RefreshView : BasicViewGroup{
    static var H:CGFloat!
    let H:CGFloat = RefreshView.H
    
    static var refreshH:CGFloat!
    let refreshH:CGFloat = RefreshView.refreshH
    
    weak var context:ViewController! = ViewController.context
    var timer = Timer()
    var poisedRunning = false;
    var animationRunning = false;
    
    var dots:[UIImageView] = []
    var textView:UILabelX!
    
    let dotDimen:CGFloat! = 14
    let dotSpacing:CGFloat! = 11
    
    static let mspf = 10.0; //millisecondsPerframeX
    static let poisedFreq = 5.0; //in waves / second
    static let refreshFreq = 1.625; //in revolutions / second
    static let refreshWavelength = 32.0; //in dots;
    
    static let spf = mspf * 0.001;
    static let frameXsPerDot = 1 / (refreshWavelength * spf * refreshFreq);
    static let radianScalingFactor = Misc.twoPi * spf * refreshFreq;
    
    required init(coder: NSCoder?) {
        super.init(coder: coder)
    }
    
    convenience init(){
        self.init(coder: nil)
    
        LayoutParams.alignParentLeftRight(subview: self)
        LayoutParams.setHeight(view: self, height: H)
    self.backgroundColor = Color.main_background
    
    let numDots = Int(context.screenWidth / dotSpacing) + 6;
    
    for i in 0 ..< numDots{
    let dot = UIImageView()
        dot.image = Drawables.refresh_dot()
    dots.append(dot)
    self.addSubview(dot);
    let startX = context.screenWidth / 2 - CGFloat(numDots) * dotSpacing / 2 + CGFloat(i) * dotSpacing;
    Layout.exact(dot, l: startX, t: H - refreshH + 10, width: dotDimen, height: dotDimen);
    }
    
    textView = UILabelX()
        textView.textAlignment = .center
        textView.textColor = Color.theme_0_875
        textView.font = ViewController.typefaceM(14)
    self.addSubview(textView);
    Layout.exact(textView, l: 0, t: H - refreshH + 30, width: context.screenWidth, height: 20);
    
    setDefault();
    }
    
    func setDefault(){
        
            self.textView.text = "Pull Down to Refresh"
            
            if(self.poisedRunning) {
                self.poisedRunning = false;
                self.defaultFunction();
            }
            
            if(self.animationRunning) {
                self.animationRunning = false;
                self.defaultFunction();
            }
            self.frameX = -1;
    }
    
    func setPoised(){
    textView.text = "Release to Refresh"
    
    if(animationRunning) {
    animationRunning = false;
    defaultFunction();
    }
    frameX = -1;
    
    if(!poisedRunning) {
    poisedRunning = true;
    Async.run(SyncInterface(runTask: poisedRunnable))
    }
    }
    
    func animateRefresh(){
    textView.text = "Fetching the Latest and Greatest"
    
    if(!animationRunning){
    animationRunning = true;
    frameX = -1;
    Async.run(SyncInterface(runTask: animationRunnable))
    }
    }
    
    func defaultFunction(){
    for dot in dots{
        let _ = dot.animate().translationX(0).translationY(0).setDuration(200);
    }
    }
    
    var poisedDir:CGFloat = 1;
    
    func poisedRunnable(){
        if !poisedRunning{ return}
        Async.run(Int64(500 / RefreshView.poisedFreq), SyncInterface(runTask: poisedRunnable))
        poisedDir *= -1;
        for i in 0 ..< dots.count{
            if(frameX - i * Int(RefreshView.frameXsPerDot) < 0) {
                let _ = dots[i].animate().translationY(dotDimen / 4 * CGFloat(Double(i % 2) - 0.5) * poisedDir).setDuration(Int64(500.0 / RefreshView.poisedFreq));
            }
        }
    }
    
    var frameX = -1;
    
    func animationRunnable() {
        if !animationRunning{ return}
        frameX += 1;
        Async.run(Int64(RefreshView.mspf), SyncInterface(runTask: animationRunnable))
    
    for i in 0 ..< dots.count{
    let radians = (Double(frameX) - Double(i) * RefreshView.frameXsPerDot) * RefreshView.radianScalingFactor;
    
    if(radians < 0){
    break;
    }
    
    if(floor(radians / RefreshView.frameXsPerDot) == 0){
    dots[i].animate().cancel();
    }

    var translationX = -dotSpacing / 2 * CGFloat(cos(radians)) + dotSpacing / 2;
    var translationY = dotSpacing / 2 * CGFloat(sin(radians))
    
    if(i % 2 == 0){
    translationX *= -1;
    translationY *= -1;
    }
    
    dots[i].translationX = translationX
    dots[i].translationY = translationY
    }
    }
}
