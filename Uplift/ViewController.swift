//
//  ViewController.swift
//  Uplift
//
//  Created by Adam Cobb on 11/1/15.
//  Copyright © 2015 Adam Cobb. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import Photos

class ViewController: UIViewControllerX, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static weak var context:ViewController!
    
    static var open = false
    static var openingNotifications = false
    
    static func typefaceR(_ size:CGFloat)->UIFont {return UIFont(name: "Avenir-Book", size: size)!}
    static func typefaceRI(_ size:CGFloat)->UIFont {return UIFont(name: "Avenir-BookOblique", size: size)!}
    static func typefaceM(_ size:CGFloat)->UIFont {return UIFont(name: "Avenir-Heavy", size: size)!}
    static func typefaceMI(_ size:CGFloat)->UIFont {return UIFont(name: "Avenir-HeavyOblique", size: size)!}
    static func typefaceB(_ size:CGFloat)->UIFont {return UIFont(name: "Avenir-Black", size: size)!}
    
    var locationManager = CLLocationManager()
    var locationViews:[UILabelX] = []
    
    //Layout
    var menuH:CGFloat!
    var titleH:CGFloat!
    
    var screenWidth:CGFloat!, screenHeight:CGFloat!, upperWindowMargin:CGFloat!
    var currentMode = 0
    var currentSubmode = [0,0,0,0]
    var currentTitle = 0
    var touch_inRect = false
    let modeNames = ["Posts","Hall of Fame","My Stuff","Options"]
    let submodeNames = [["Local", "Regional", "Global"], ["Users", "Posts"], ["Notifications", "Activity"], [""]]
    let modeImages = [#imageLiteral(resourceName: "mode0"), #imageLiteral(resourceName: "mode1"), #imageLiteral(resourceName: "mode2"), #imageLiteral(resourceName: "mode3")]
    
    @IBOutlet weak var layout_all: UIView!
    @IBOutlet weak var layout_main: UIView!
    @IBOutlet weak var layout_tutorial: UIView!
    @IBOutlet weak var layout_splash: UIView!
    @IBOutlet weak var splash_circle:UIImageView!
    @IBOutlet weak var splash_image:UIImageView!
    @IBOutlet weak var layout_login: UIView!
    @IBOutlet weak var layout_windows: UIView!
    @IBOutlet weak var layout_dialog: UIView!
    
    var layout_top:BasicViewGroup!
    
    var menu_indicator:UIImageViewX!
    var menu_notifications:UILabelX!
    var menu_notificationsR:CGFloat = 0
    
    var title_content:UIView!
    var title_text:UILabelX!
    var title_indicator:UIImageViewX!
    var title_notifications:UILabelX!
    var title_notificationsR:CGFloat = 0
    
    var menu_icons:[UIImageViewX] = []
    var title_icons:[UILabelX]? = nil
    var view_frames:[UIView] = []
    var view_scrolls:[UIScrollView] = []
    var view_layouts:[VerticalLinearLayout] = []
    var view_refreshes:[RefreshView] = []
    var view_switches:[SortSwitch] = []
    var reachedBottom = [false, false, false, false, false, false, false, true]
    var refreshing = [false, false, false, false, false, false, false, false]
    var lastRefresh:[Int64] = [0, 0, 0, 0, 0, 0, 0, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //CONTEXTS
        ViewController.context = self;
        ContentCreator.context = self;
        WindowBase.context = self;
        LogIn.context = self;
        Update.context = self;
        TouchController.context = self;
        TutorialController.context = self;
        
        //CONSTANTS
        menuH = 52
        titleH = 44
        WindowBase.topH = menuH;
        WindowBase.expandH = titleH;
        TouchController.boxDimen = 24
        HeaderView.H = 44
        RefreshView.H = 50 + titleH; //can't be more than dp(50) + titleH
        RefreshView.refreshH = 48
        SortSwitch.H = 44
        TitleAndLinkView.H = 44
        ComposeView.bottomH = 44
        
        WindowBase.layout_windows = layout_windows
        
        locationManager.delegate = self
        
        if(!RecyclerImageView.checkingUndrawn) {
            RecyclerImageView.checkingUndrawn = true;
            Async.run(Async.PRIORITY_WAITING, RecyclerImageView.checkUndrawn)
        }
        
        //iOS only:
        
        UIView.transition(with: self.splash_image,
                          duration: 2,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.splash_image.image = #imageLiteral(resourceName: "logo_darkfull")
        },
                          completion: nil)
        
        UIView.transition(with: self.splash_circle,
                          duration: 2,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.splash_circle.image = Drawables.circle_white_shadow()
        },
                          completion: nil)
    }

        var inited = false
    
    //onWindowFocusChanged, hasFocus == true
        func onWindowFocused(){
            
            if (!inited) {
                inited = true;
                screenWidth = layout_all.width
                screenHeight = layout_all.height
                
                let loc = view.superview!.convert(layout_all.frame.origin /*leave it*/, to: nil)
                upperWindowMargin = loc.y
                
                menu_notificationsR = screenWidth * 5 / 8 - 19;
                
                init_all();
            }
            
            if (ViewController.openingNotifications) {
                currentMode = 2;
                currentSubmode[2] = 0;
                animate_all();
                ViewController.openingNotifications = false;
            }
        }
    
    override func onStart(){
        super.onStart()
        ViewController.open = true
    }
    
    override func onStop(){
        super.onStop()
        ViewController.open = false
    }
    
    override func onResume() {
        super.onResume()
        
        onWindowFocused() //iOS only
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 20
            if #available(iOS 9.0, *) {
                locationManager.requestLocation()
            }
            if let location = locationManager.location{
                recordLocation(location)
            }
            locationManager.startUpdatingLocation()
        }
    }
    
    //onPause
    override func onPause() {
        super.onPause()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus){
        Async.run(SyncInterface(runTask: {
            if status == .denied{
                Toast.makeText(self, "Looks like you have denied Uplift access to your location.  To use Uplift please grant us this permission in your phone's settings.", Toast.LENGTH_LONG)
            }
            LogIn.update()
            self.viewDidAppear(false)
        }))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    let POST_PICTURE = 1;
    let PROFILE_PICTURE = 2;
    let POST_VIDEO = 3;
    var pictureCallback:PictureIntentCallback?
    var videoCallback:VideoIntentCallback?
    //TODO Uri selectedMedia;
    
    var requestCode = 0
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finish 1")
        if var image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let minImageScale = min(2048 / image.size.width, 2048 / image.size.height);
            if (minImageScale < 1) {
                image = image.scaleImage(toSize: CGSize(width: image.size.width * minImageScale, height: image.size.height * minImageScale))
            }
            
            print("did finish 2")
            
            if (requestCode == POST_PICTURE) {
                pictureCallback!.success(image);
            }
            
            if (requestCode == PROFILE_PICTURE) {
                print("did finish 3")
                let _ = WindowWithCrop(image: image);
            }
        }else{
            Toast.makeText(self, "Error receiving image.", Toast.LENGTH_LONG)
        }
    
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }

func pictureIntent( requestCode:Int){
    
    self.requestCode = requestCode
    
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = false
    picker.sourceType = .photoLibrary
    present(picker, animated: true, completion: nil)
}

    func videoIntent(requestCode:Int){
    
}

    func setModeToRatio(_ ratio:CGFloat){
    var modes = Int(round(ratio))
    for i in 0 ..< 4{
        if(modes < submodeNames[i].count){
            currentMode = i;
            currentSubmode[i] = modes;
            return;
        }
        modes -= submodeNames[i].count;
    }
}

func currentModeRatio()->Int{
    var ratio = 0;
    for i in stride(from: 0, through: currentMode, by: 1){
        if(i != currentMode){
            ratio += submodeNames[i].count;
        }else{
            ratio += currentSubmode[i];
        }
    }
    return max(0, ratio);
}

    func currentActualRatio()->CGFloat{
    return -view_frames[0].translationX / screenWidth;
}

    func getMenuRatio(_ totalRatio:CGFloat)->CGFloat{
        var totalRatio = totalRatio
    
    if(totalRatio < 0 || totalRatio > CGFloat(view_scrolls.count - 1)){
        return -1;
    }
    
    for i in 0 ..< 4{
        totalRatio -= CGFloat(submodeNames[i].count)
        if(totalRatio <= -1 || i == 3){
            return CGFloat(i)
        }else if(totalRatio < 0){
            return CGFloat(i) + totalRatio + 1
        }
    }
    return -1;
}

    func getTitleRatio(_ totalRatio:CGFloat)->CGFloat{
    var totalRatio = totalRatio
        
    for i in 0 ..< 4{
        if(i == currentTitle) {
            if(totalRatio <= 0){
                return 0;
            }else if (totalRatio <= CGFloat(submodeNames[i].count - 1)) {
                return totalRatio;
            } else if (totalRatio <= CGFloat(submodeNames[i].count)) {
                return CGFloat(submodeNames[i].count - 1)
            }
        }
        totalRatio -= CGFloat(submodeNames[i].count)
    }
    return 0;
}

func init_all() {
    
    view_init();
    
    layout_top = BasicViewGroup();
    layout_main.addSubview(layout_top);
    Layout.exact(layout_top, width: screenWidth, height: menuH + titleH + 2);
    
    let topShadow = ContentCreator.shadow(top: true, alpha: 0.15);
    layout_top.addSubview(topShadow);
    Layout.exact(topShadow, l: 0, t: menuH + titleH, width: screenWidth, height: 2);
    
    title_init();
    menu_init();
    
    let top = ContentCreator.shadow(top: true, alpha: 0.4)
    LayoutParams.alignParentTop(subview: top)
    layout_all.addSubview(top);
    let bottom = ContentCreator.shadow(top: false, alpha: 0.3)
    LayoutParams.alignParentBottom(subview: bottom)
    layout_all.addSubview(bottom);
    
    title_update();
    move_all(CGFloat(currentModeRatio()));
    
    notifications_update();
    notifications_refreshAsync();
    
    LogIn.update();
}

func animate_all(){
    let duration = 200 + Int64(abs(60 * (CGFloat(currentModeRatio()) - currentActualRatio())))
    title_animate(duration);
    menu_animate(duration);
    view_animate(duration);
}

    func move_all(_ ratio:CGFloat){
    menu_move(getMenuRatio(ratio));
    title_move(getTitleRatio(ratio));
    view_move(ratio);
}

func menu_init(){
    
    let layout_menu = BasicViewGroup();
    layout_menu.backgroundImage = Drawables.theme_gradient()
    layout_top.addSubview(layout_menu);
    Layout.exact(layout_menu, width: screenWidth, height: menuH);
    
    for i in 0 ..< 4{
        let item = UIImageViewX()
        item.tag = i
        item.setInsets(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        item.image = modeImages[i]
        if(currentMode == i){
            item.alpha = 1
            item.translationY = -2
        }else{
            item.alpha = 0.6
            item.translationY = 0
        }
        layout_menu.addSubview(item);
        Layout.exact(item, l: screenWidth / 4 * CGFloat(i), t: -2, width: screenWidth / 4, height: menuH + 4);
        menu_icons.append(item)
        
        TouchController.setUniversalOnTouchListener(item, allowSpreadMovement: false, onOffCallback: OnOffCallback(on: {
            if(self.currentMode == i){
                item.backgroundColor = Color.theme_0_875
            }else{
                item.backgroundColor = Color.theme_0_75
            }
        }, off: {
            item.backgroundColor = .clear
        }), clickCallback: ClickCallback(execute: {
            if(self.currentMode == i){
                self.view_scrolls[self.currentModeRatio()].setContentOffset(.zero, animated: true)
            }
            self.currentMode = i;
            
            self.animate_all();
        }))
    }
    
    menu_indicator = UIImageViewX()
    menu_indicator.image = #imageLiteral(resourceName: "menu_indicator")
    layout_menu.addSubview(menu_indicator);
    Layout.exactUp(menu_indicator, l: 0, b: menuH, width: screenWidth / 4, height: 8);
    
    menu_notifications = UILabelX()
    menu_notifications.tag = 2
    menu_notifications.setInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6))
    menu_notifications.textColor = Color.WHITE
    menu_notifications.font = ViewController.typefaceM(17)
    menu_notifications.backgroundColor = Color.theme_0_625
    layout_menu.addSubview(menu_notifications);
    
    TouchController.setUniversalOnTouchListener(menu_notifications, allowSpreadMovement: false, onOffCallback: OnOffCallback(on: {
        self.menu_notifications.backgroundColor = Color.theme_0_75
    }, off: {
        self.menu_notifications.backgroundColor = Color.theme_0_625
    }), clickCallback: ClickCallback(execute: {
        if(self.currentMode == 2){
            self.view_scrolls[self.currentModeRatio()].setContentOffset(.zero, animated: true)
        }
        self.currentMode = 2;
        
        self.currentSubmode[2] = 0;
        
        self.animate_all();
    }))
}

func notifications_refreshAsync(){
    Async.run(Async.PRIORITY_INTERNETBIG, AsyncInterface(runTask: {
        self.notifications_refreshSync();
    }))
}

func notifications_refreshSync(){
    
    if(!LogIn.isLoggedIn()){
        return;
    }
    
    do {
    
    let query = PFQuery(className: "Notification");
        query.whereKey("userId", equalTo: CurrentUser.userId())
        query.whereKey("read", equalTo: false)
        
    Files.writeInteger("unread", try query.findObjects().count);
        
        Async.run(SyncInterface(runTask:{
            self.notifications_update()
        }))
    
    }catch{}
}

func notifications_update(){
    let unread = Files.readInteger("unread", 0);
    if(unread == 0){
        menu_notifications.isHiddenX = true
        title_notifications.isHiddenX = true
    }else{
        menu_notifications.isHiddenX = false
        menu_notifications.text = String(unread)
        var notificationDimens = Measure.wrap(menu_notifications);
        Layout.wrapWLeft(menu_notifications, r: menu_notificationsR, t: (menuH - notificationDimens.height) / 2, height: notificationDimens.height);
        
        title_notifications.isHiddenX = false
        if(currentTitle == 2) {
            title_notifications.text = String(unread)
            notificationDimens = Measure.wrap(menu_notifications);
            Layout.wrapWLeft(title_notifications, r: title_notificationsR, t: (titleH - notificationDimens.height) / 2, height: notificationDimens.height);
        }
    }
}

    func menu_animate(_ duration:Int64){
    
    var _ = menu_indicator.animate().translationX(screenWidth / 4 * CGFloat(currentMode)).setDuration(duration).setInterpolator(.decelerate);
    
    let ratioToGo = max(0.001, abs(CGFloat(currentMode) - getMenuRatio(currentActualRatio())))
        let segmentDuration = min(Int64(CGFloat(duration) / ratioToGo), duration);
    
    for i in 0 ..< 4{
        let item = menu_icons[i];
        if(i == currentMode){
            let startDelay = duration - segmentDuration;
            let _ = item.animate().alpha(1).translationY(-2).setStartDelay(startDelay).setDuration(segmentDuration).setListener(nil);
        }else if(CGFloat(i) != getMenuRatio(currentActualRatio()) && CGFloat(currentMode - i).sign() == (CGFloat(i) - getMenuRatio(currentActualRatio())).sign()){
            var startDelay:Int64 = 0;
            if(abs(CGFloat(i) - getMenuRatio(currentActualRatio())) > 1){
                startDelay = segmentDuration * Int64(abs(CGFloat(i) - getMenuRatio(currentActualRatio())) - 1);
            }
            let _ = item.animate().alpha(1).translationY(-2).setStartDelay(startDelay).setDuration(segmentDuration).setListener(AnimatorListener(onAnimationEnd:{
                let _ = item.animate().alpha(0.6).translationY(0).setStartDelay(0).setDuration(segmentDuration).setListener(nil);
            }))
        }else{
            let _ = item.animate().alpha(0.6).translationY(0).setStartDelay(0).setDuration(Int64(CGFloat(duration) / ratioToGo * (1 - (10 - ratioToGo).remainder(dividingBy: 1)))).setListener(nil);
        }
    }
}

    func menu_move(_ ratio:CGFloat){
    menu_indicator.translationX = ratio * screenWidth / 4
    for i in 0 ..< 4 {
        if(abs(CGFloat(i) - ratio) <= 1) {
            menu_icons[i].alpha = 1 - 0.4 * abs(CGFloat(i) - ratio)
            menu_icons[i].translationY = -2 + 2 * abs(CGFloat(i) - ratio);
        }
    }
}

func title_init(){
    let layout_title = BasicViewGroup();
    layout_title.backgroundColor = Color.title_background
    layout_top.addSubview(layout_title);
    Layout.exact(layout_title, l: 0, t: menuH, width: screenWidth, height: titleH);
    
    title_content = BasicViewGroup();
    layout_title.addSubview(title_content);
    Layout.exact(title_content, width: screenWidth, height: titleH);
    
    title_notifications = UILabelX()
    title_notifications.tag = 0
    title_notifications.setInsets(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6))
    title_notifications.textColor = Color.title_textColor
    title_notifications.font = ViewController.typefaceM(17)
    
    let highlight = UIView()
    highlight.backgroundColor = Color.title_highlight
    layout_title.addSubview(highlight);
    Layout.exactUp(highlight, l: 0, b: titleH, width: screenWidth, height: 1);
    
    TouchController.setUniversalOnTouchListener(layout_title, allowSpreadMovement: false, onOffCallback: OnOffCallback(on:{
        layout_title.backgroundColor = Color.title_touch
    }, off: {
        layout_title.backgroundColor = Color.title_background
    }), clickCallback: ClickCallback(execute: {
        self.view_scrolls[self.currentModeRatio()].setContentOffset(.zero, animated: true)
        self.animate_all()
    }))
    
    TouchController.setUniversalOnTouchListener(title_notifications, allowSpreadMovement: false, onOffCallback: OnOffCallback(on:{
        self.title_notifications.backgroundColor = Color.title_touch
    }, off: {
        self.title_notifications.backgroundColor = Color.title_highlight
    }), clickCallback: ClickCallback(execute: {
        if self.currentSubmode[2] == 0{
        self.view_scrolls[2].setContentOffset(.zero, animated: true)
        }
        
        self.currentSubmode[2] = 0
        
        self.animate_all()
    }))
}

    func title_animate(_ duration:Int64){
    
    let _ = layout_top.animate().translationY(0).setDuration(150).setInterpolator( .decelerate);
    
    if(getTitleRatio(currentActualRatio()) != getTitleRatio(CGFloat(currentModeRatio())) && currentTitle == currentMode && title_icons != nil) {
        
        title_indicator.animate().cancel();
        let _ = title_indicator.animate().translationX(screenWidth / 4 * getTitleRatio(CGFloat(currentModeRatio()))).setDuration(duration).setInterpolator(.decelerate);
        
        let ratioToGo = max(0001, abs(getTitleRatio(CGFloat(currentModeRatio())) - getTitleRatio(currentActualRatio())));
        let segmentDuration = min(Int64(CGFloat(duration) / ratioToGo), duration);
        
        for i in 0 ..< submodeNames[currentTitle].count {
            let item = title_icons![i];
            item.animate().cancel();
            if (i == currentSubmode[currentTitle]) {
                let startDelay = duration - segmentDuration;
                let _ = item.animate().alpha(1).translationY(-2).setStartDelay(startDelay).setDuration(segmentDuration).setListener(nil);
            } else if (CGFloat(abs(i - currentSubmode[currentTitle])) < ratioToGo && abs(CGFloat(i) - getTitleRatio(currentActualRatio())) < ratioToGo) {
                var startDelay:Int64 = 0;
                if (abs(CGFloat(i) - getTitleRatio(currentActualRatio())) > 1) {
                    startDelay = segmentDuration * Int64(abs(CGFloat(i) - getTitleRatio(currentActualRatio())) - 1);
                }
                let _ = item.animate().alpha(1).translationY(-2).setStartDelay(startDelay).setDuration(segmentDuration).setListener(AnimatorListener(onAnimationEnd: {
                    let _ = item.animate().alpha(0.6).translationY(0).setStartDelay(0).setDuration(segmentDuration).setListener(nil);
                }))
                
            } else {
                let _ = item.animate().alpha(0.6).translationY(0).setStartDelay(0).setDuration(Int64(CGFloat(duration) / ratioToGo * (1 - (10 - ratioToGo).remainder(dividingBy: 1)))).setListener(nil);
            }
        }
    }
    
    if(currentMode == currentTitle){
        return;
    }
    
    //If currentMode has changed:
    
        let newTitleDuration:Int64 = 300;
    let distance = screenWidth / 16;//dp(20);
    let direction = (CGFloat(currentModeRatio()) - currentActualRatio()).sign()
    
        let _ = title_content.animate().translationX(distance * direction).alpha(0).setDuration(newTitleDuration / 2).setInterpolator(.accelerate).setListener( AnimatorListener(onAnimationEnd:{
            self.title_update();
            
            self.title_content.translationX = -distance * direction
            let _ = self.title_content.animate().translationX(0).alpha(1).setDuration(newTitleDuration / 2).setInterpolator(.decelerate).setListener(nil);
        }))
}

func title_update(){
    title_content.removeAllViews();
    if title_icons != nil{
        title_icons!.removeAll()
        title_icons = nil
    }
    
    currentTitle = currentMode;
    
    title_text = UILabelX()
    title_text.font = ViewController.typefaceB(20)
    title_text.textColor = Color.title_textColor
    title_text.text = modeNames[currentTitle]
    title_content.addSubview(title_text);
    Layout.wrapW(title_text, l: 8, t: 0, height: titleH);
    
    let items = submodeNames[currentTitle].count
    
    if(items > 1){
        title_icons = []
        for i in 0 ..< items{
            let item = UILabelX()
            item.tag = i
            item.textAlignment = .center
            item.text = submodeNames[currentTitle][i]
            item.textColor = Color.title_textColor
            item.font = ViewController.typefaceM(screenWidth > 380 ? 17 : 14)
            
            if(currentSubmode[currentTitle] == i){
                item.alpha = 1
                item.translationY = -2
            }else{
                item.alpha = 0.6
                item.translationY = 0
            }
            title_content.addSubview(item);
            
            if(currentTitle == 2 && i == 0){
                title_notificationsR = screenWidth * 5 / 8 - Measure.wrapW(item, height: titleH) / 2 - 3;
                title_content.addSubview(title_notifications);
                notifications_update();
            }
            
            let width = max(screenWidth / 4, Measure.wrapW(item, height: titleH + 4));
            Layout.exact(item, l: screenWidth / 8 * CGFloat(9 - 2 * (items - i)) - width / 2, t: -2, width: width, height: titleH + 4);
            title_icons!.append(item)
            
            TouchController.setUniversalOnTouchListener(item, allowSpreadMovement: false, onOffCallback: OnOffCallback(on:{
                if(self.currentSubmode[self.currentMode] == i){
                item.backgroundColor = Color.title_touch
                }else{
                item.backgroundColor = Color.title_touch_extra
                }
            }, off: {
                item.backgroundColor = .clear
            }), clickCallback: ClickCallback(execute: {
                if(self.currentSubmode[self.currentTitle] == i){
                    self.view_scrolls[self.currentModeRatio()].setContentOffset(.zero, animated: true)
                }
                
                self.currentSubmode[self.currentTitle] = i;
                
                self.animate_all();
            }))
        }
        
        title_indicator = UIImageViewX()
        title_indicator.image = #imageLiteral(resourceName: "title_indicator")
        title_indicator.translationX = screenWidth / 4 * getTitleRatio(CGFloat(currentModeRatio()))
        title_content.addSubview(title_indicator);
        Layout.exactUp(title_indicator, l: screenWidth / 4 * CGFloat(4 - items), b: titleH, width: screenWidth / 4, height: 8);
    }
}

    func title_move(_ ratio:CGFloat){
    if(title_icons == nil){
        return;
    }
    
    title_indicator.translationX = ratio * screenWidth / 4
    for i in 0 ..< title_icons!.count {
        let amountEnhanced = max(0, 1 - abs(CGFloat(i) - ratio));
        title_icons![i].alpha = 0.6 + 0.4 * amountEnhanced
        title_icons![i].translationY = -2 * amountEnhanced
    }
}

func view_init(){
    
    for i in 0 ..< 4{
        for j in 0 ..< submodeNames[i].count{
            
            let scrollNum = Misc.modeToPage(i, j);
            
            let frame = UIView()
            view_frames.append(frame)
            
            let scroll = UIScrollViewX()
            scroll.setInsets(UIEdgeInsets(top: 50 + menuH + titleH - RefreshView.H, left: 0, bottom: 0, right: 0))
            TouchController.setUniversalOnTouchListener(scroll, allowSpreadMovement: true);
            scroll.showsVerticalScrollIndicator = false
            scroll.backgroundColor = Color.theme
            view_scrolls.append(scroll)
            
            let layout = VerticalLinearLayout()
            LayoutParams.alignParentScrollVertical(subview: layout)
            
            view_layouts.append(layout)
            view_scrolls[scrollNum].addSubview(view_layouts[scrollNum]);
            view_frames[scrollNum].addSubview(view_scrolls[scrollNum])
            LayoutParams.alignParentLeftRight(subview: scroll)
            LayoutParams.alignParentTopBottom(subview: scroll)
            
            view_refreshes.append(RefreshView())
            
            view_switches.append(SortSwitch(comments: false, pageName: "view" + String(scrollNum), callback: SortCallback(execute:{sortByUplifts in
                self.refreshing[scrollNum] = false;
                self.reachedBottom[scrollNum] = false;
                Update.updateLayout(i, j, true, UpdateCallback(execute: {
                    Refresh.refreshPage(i, j);
                }))
            })))
            
            scroll.scrollChangedListeners.append({
                if (!LogIn.isLoggedIn() || scrollNum != self.currentModeRatio() || WindowBase.topShownWindow() != nil) {
                    return;
                }
                
                if self.layout_top.translationY < -scroll.contentOffset.y{
                    self.layout_top.animate().cancel()
                    self.layout_top.translationY = 0
                }
                
                let num = Misc.modeToPage(self.currentMode, self.currentSubmode[self.currentMode]);
                if (!self.reachedBottom[num] && self.view_layouts[num].height - self.view_scrolls[num].contentOffset.y - self.view_scrolls[num].height < 1000) {
                    
                    Refresh.fetchNextItems(self.currentMode, self.currentSubmode[self.currentMode], self.view_switches[num].byUplifts, 10);
                }
            })
            
            layout_main.addSubview(view_frames[scrollNum]);
            Layout.exact(view_frames[scrollNum], l: 0, t: -50, width: screenWidth, height: screenHeight + 50);
        }
    }
}

    func view_move(_ ratio:CGFloat){
    
    for i in 0 ..< view_scrolls.count{
        let transRatio = CGFloat(i) - ratio;
        
        view_frames[i].translationX = screenWidth * transRatio
        
        if(transRatio > -1 && transRatio < 1){
            view_frames[i].isHiddenX = false
        }else{
            view_frames[i].isHiddenX = true
        }
    }
}

    func view_animate(_ duration:Int64){
    
    for i in 0 ..< view_scrolls.count{
        
        view_frames[i].animate().cancel();
        
        if(Misc.isBetween(CGFloat(i), num1: currentActualRatio(), num2: CGFloat(currentModeRatio()), orWithin1: true)){
            view_frames[i].isHiddenX = false
        }else{
            view_frames[i].isHiddenX = true
        }
        
        let _ = view_frames[i].animate().translationX(screenWidth * CGFloat(i - currentModeRatio())).setDuration(duration).setInterpolator(.decelerate).setListener(AnimatorListener(onAnimationEnd: {
            if(!Misc.isBetween(self.currentActualRatio(), num1: CGFloat(i) - 1, num2: CGFloat(i) + 1, orWithin1: false)){
                self.view_frames[i].isHiddenX = true
            }
            
            if(i == self.currentModeRatio() && LogIn.isLoggedIn() && Int64(Date().timeIntervalSince1970 * 1000) - self.lastRefresh[i] > (i == 5 ? 2 : 20) * 60 * 1000){
            Refresh.refreshPage(Misc.pageToModes(self.currentModeRatio())[0], Misc.pageToModes(self.currentModeRatio())[1]);
            }
        }));
    }
}

    func setMainPaddings(_ targetTranslation:CGFloat){
    view_scrolls[currentModeRatio()].setInsets(UIEdgeInsets(top: 50 + menuH + titleH + targetTranslation - RefreshView.H, left: 0, bottom: 0, right: 0))
    view_layouts[currentModeRatio()].setInsets(UIEdgeInsets(top: -targetTranslation, left: 0, bottom: 0, right: 0))
}

    func recordLocation(_ location:CLLocation) {
        
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
    
    Files.writeDouble("latitude", lat);
    Files.writeDouble("longitude", lng);
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            if let placemarks = placemarks{
            if let address = placemarks.first{
                var locationName = address.locality != nil ? address.locality! + ", " : address.subLocality != nil ? address.subLocality! + ", " : "";
                
                if(address.isoCountryCode == "US") {
                    locationName += StateNameAbbreviator.getStateAbbreviation(address: address) + ", USA";
                }else if(address.isoCountryCode == "CA"){
                    locationName += StateNameAbbreviator.getStateAbbreviation(address: address) + ", CAN";
                }else if let country = address.country{
                    locationName += country
                }else{
                    locationName += "Earth"
                }
                
                Files.writeString("location", locationName);
            }
            }
        })
    
    //} catch (Exception e) {}
    
    var locationName = Files.readString("location", "");
    
    if(locationName.lastIndexOf(",") != -1){
        locationName = locationName.substring(0, locationName.lastIndexOf(","));
    }
    
    for locationView in locationViews{
        locationView.text = locationName
    }
}

func locationManager(_ manager: CLLocationManager,
                     didUpdateLocations locations: [CLLocation]){
    recordLocation(locations.last!)
}

    func handleUplift(postId:String, uplifted:Bool, isComment:Bool){
    
        var map:[String : Any] = [:]
        map["userId"] = CurrentUser.userId()
        map["objectId"] = postId
        map["isComment"] = isComment
    
        let function = uplifted ? "uplift" : "unuplift"
        
        PFCloud.callFunction(inBackground: function, withParameters: map)
    
    for instance in WindowBase.instances.reversed() {
        
        if let content = instance.content{
            if let postView = content.viewWithTag(Tag.getTag(postId)) as? PostView{
                if let upliftView = postView.upliftView{
                    upliftView.animateUplift(newuplifted: uplifted)
                }
            }
        }
    }
    
    if (isComment) {
        return;
    }
    
    for layout in view_layouts {
        if let postView = layout.viewWithTag(Tag.getTag(postId)) as? PostView{
            if let upliftView = postView.upliftView{
                upliftView.animateUplift(newuplifted: uplifted)
            }
        }
    }
}

    func handleFlag(postId:String, flagged:Bool, isComment:Bool, postOrComment:PostOrCommentObject) {
    
    if (flagged) {
        postOrComment.flag();
    } else {
        postOrComment.unFlag();
    }
        
        for instance in WindowBase.instances.reversed() {
            
            if let content = instance.content{
                if let postView = content.viewWithTag(Tag.getTag(postId)) as? PostView{
                    postView.flag(newflagged: flagged)
                }
            }
        }
        
        if (isComment) {
            return;
        }
        
        for layout in view_layouts {
            if let postView = layout.viewWithTag(Tag.getTag(postId)) as? PostView{
                postView.flag(newflagged: flagged)
            }
        }
}

    func handleComment( postId:String, numComments:Int) {
        
        for instance in WindowBase.instances.reversed() {
            
            if let content = instance.content{
                if let postView = content.viewWithTag(Tag.getTag(postId)) as? PostView{
                    postView.populateBottom(comments: numComments)
                }
            }
        }
        
        for layout in view_layouts {
            if let postView = layout.viewWithTag(Tag.getTag(postId)) as? PostView{
                postView.populateBottom(comments: numComments)
            }
        }
}

    func handleDelete(postId:String, isComment:Bool, postOrComment:PostOrCommentObject) {
    
    let text = postOrComment.getText()!;
        
        if isComment{
            var map:[String : Any] = [:]
            map["objectId"] = postId
            map["parentId"] = (postOrComment.object["parentId"]) as! String
            print("delete comment with map " + map.description)
            
            PFCloud.callFunction(inBackground: "deleteComment", withParameters: map, block: { (result: Any?, error: Error?)->Void in
                if let error = error{
                    print("delete comment error: " + error.localizedDescription)
                }else{
                    print("delete comment success")
                }
            })
        }else{
        postOrComment.object.deleteInBackground(block: {success, e in
            if success{
                Toast.makeText(.context, "Successfully deleted " + (isComment ? "comment" : "post") + " \"" + text + "\"", Toast.LENGTH_LONG)
            } else {
                Toast.makeText(.context, "Failed to delete " + (isComment ? "comment" : "post") + " \"" + text + "\"", Toast.LENGTH_LONG)
                print("Deletion error: " + e!.localizedDescription)
                
            }
        })
        }
        
        for instance in WindowBase.instances.reversed() {
            if !isComment && instance is WindowWithComments{
                instance.hideFrame(send: false)
            }
            if let content = instance.content{
                if let postView = content.viewWithTag(Tag.getTag(postId)) as? PostView{
                    if(!isComment){
                        let subviews = postView.superview!.subviews
                        subviews[subviews.index(of: postView)! - 1].isHiddenX = true
                    }
                    postView.isHiddenX = true
                }
            }
        }
        
        if (isComment) {
            //delete comment from comments lists
            let parentId = (postOrComment as! CommentObject).getParentId();
            
            //for true and false
            for i in 0 ..< 2 {
                let sortByUplifts = i == 0;
                var commentsList = Local.readCommentsList(parentId, sortByUplifts);
                let commentsIndex = Local.readCommentsIndex(parentId, sortByUplifts);
                let indexOfComment = commentsList.index(of: postId);
                if let indexOfComment = indexOfComment {
                    commentsList.remove(at: indexOfComment);
                    Local.writeCommentsList(parentId, sortByUplifts, commentsList);
                    Local.writeCommentsIndex(parentId, sortByUplifts, (indexOfComment > commentsIndex) ? commentsIndex : commentsIndex - 1);
                }
            }
            return;
        }
        
        for i in 0 ..< modeNames.count {
            for j in 0 ..< submodeNames[i].count{
                
                for k in 0 ..< 2 {
                    let sortByUplifts = k == 0;
                    var postsList = Local.readList(i, j, sortByUplifts);
                    let postsIndex = Local.readIndex(i, j, sortByUplifts);
                    let indexOfPost = postsList.index(of: postId);
                    if let indexOfPost = indexOfPost {
                        postsList.remove(at: indexOfPost);
                        Local.writeList(i, j, sortByUplifts, postsList);
                        Local.writeIndex(i, j, sortByUplifts, (indexOfPost > postsIndex) ? postsIndex : postsIndex - 1);
                    }
                }
                
            if let postView = view_layouts[Misc.modeToPage(i, j)].viewWithTag(Tag.getTag(postId)) as? PostView{
                
                    let subviews = postView.superview!.subviews
                subviews[subviews.index(of: postView)! - 1].isHiddenX = true
                postView.isHiddenX = true
            }
        }
        }
    
    animate_all();
}

func clearAllFocus(){
    
    view.endEditing(true)
}

var outOfMemoryPoppedUp = false;
    
func outOfMemoryPopup(){
    if(!outOfMemoryPoppedUp){
        outOfMemoryPoppedUp = true;
        Async.run(SyncInterface(runTask: {
            Dialog.showTextDialog(title: "Imminent Failure:\nDevice Out of Memory", text: "Unfortunately, we have detected that your device is out of runtime memory, a condition which may force Uplift to crash very shortly.  This could be because your device is running an old version of Android that was not designed to handle interfaces of high complexity." +
                "\n\n" +
                "If Uplift does indeed crash and you think this failure should not have occurred on your device, please report the crash to alert us of the problem." +
                "\n\n" +
                "Regardless of whether you are able to use our app, we hope you continue to Uplift the World forever and always.", negativeText: nil, positiveText: "Okay", positiveCallback: DialogCallback(execute: {
                    return true
                }))
        }))
    }
}
}

