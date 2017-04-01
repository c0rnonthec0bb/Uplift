//
//  Temp.swift
//  Uplift
//
//  Created by Adam Cobb on 1/7/17.
//  Copyright © 2017 Adam Cobb. All rights reserved.
//
/*
import UIKit


// Shim for dispatch_once and DISPATCH_CURRENT_QUEUE_LABEL in swift 3 from http://stackoverflow.com/a/38311178 and https://lists.swift.org/pipermail/swift-users/Week-of-Mon-20160613/002280.html
public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:(Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
    
    class var currentLabel: String? {
        return String(validatingUTF8: __dispatch_queue_get_label(nil))
    }
}

extension UIView {
    open override class func initialize() {
        
        // make sure this isn't a subclass
        if self !== UIView.self {
            return
        }
        
        DispatchQueue.once(token: "NBUIKitMainThreadGuardInitialize", block: { () in
            let swizzle = { (cls: AnyClass, originalSelector: Selector, swizzledSelector: Selector) in
                let originalMethod = class_getInstanceMethod(cls, originalSelector)
                let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
                
                let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
                
                if didAddMethod {
                    class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
                } else {
                    method_exchangeImplementations(originalMethod, swizzledMethod);
                }
            }
            for method in ["setNeedsLayout", "setNeedsDisplay", "setNeedsDisplayInRect"] {
                swizzle(self, Selector(method), Selector("nb_\(method)"))
            }
        })
    }
    
    // MARK: - Method Swizzling
    
    private func nb_mainThreadCheck() {
        // iOS 8 layouts the MFMailComposeController in a background thread on an UIKit queue.
        // https://github.com/PSPDFKit/PSPDFKit/issues/1423
        if !Thread.isMainThread && DispatchQueue.currentLabel?.hasPrefix("UIKit") != true  && self.window != nil {
            let stack = Thread.callStackSymbols.joined(separator: "\n")
            assert(false, "\nERROR: All calls to UIKit need to happen on the main thread. You have a bug in your code. Use dispatch_async(dispatch_get_main_queue()) { } if you're unsure what thread you're in.\n\nBreak on nb_mainThreadCheck to find out where.\n\nStacktrace:\n\(stack)")
        }
    }
    
    func nb_setNeedsLayout() {
        self.nb_mainThreadCheck()
        self.nb_setNeedsLayout()
    }
    
    func nb_setNeedsDisplay() {
        self.nb_mainThreadCheck()
        self.nb_setNeedsDisplay()
    }
    
    func nb_setNeedsDisplayInRect(rect: CGRect) {
        self.nb_mainThreadCheck()
        self.nb_setNeedsDisplayInRect(rect: rect)
    }
}*/
