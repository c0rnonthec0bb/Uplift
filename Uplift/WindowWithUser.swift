//
//  WindowWithUser.swift
//  Uplift
//
//  Created by Adam Cobb on 12/29/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class WindowWithUser: WindowBase {
    var user:UserObject!
    
    var refreshing = false;
    var reachedBottom = false;
    private var postArrayByUplifts:[String] = []
    private var postArrayByRecent:[String] = []
    private var indexByUplifts = 0;
    private var indexByRecent = 0;
    var postsShown = 0;
    
    var scroll:UIScrollViewX!
    var refreshView:RefreshView!
    var sortSwitch:SortSwitch!
    
    var profileLayout:BasicViewGroup!
    var profile:RecyclerImageView!
    var profileCover:UIView!
    var numPosts:UILabelX!
    var numUplifts:UILabelX!
    var rank:UILabelX!
    var charityView:UIView! // or loading spinner
    var postsLayout:VerticalLinearLayout!
    
    public init(user:UserObject){
    super.init();
    
    if(WindowBase.topShownWindow() != nil && WindowBase.topShownWindow() is  WindowWithUser){
        WindowBase.instances.remove(element: self);
    return;
    }
    
    self.user = user;
    
    buildTitle(user.getName()!);
    buildUser(user);
    buildFrame();
    showFrame();
    }
    
    func getPostArray(sortByUplifts:Bool)->[String]{
        if(sortByUplifts){
    return postArrayByUplifts;
        }
    return postArrayByRecent;
    }
    
    func setPostArray(sortByUplifts:Bool, array:[String]){
        if(sortByUplifts){
    postArrayByUplifts = array;
        }else{
    postArrayByRecent = array;
        }
    }
    
    func getIndex(sortByUplifts:Bool)->Int{
        if(sortByUplifts){
            return indexByUplifts;
        }
    return indexByRecent;
    }
    
    func setIndex(sortByUplifts:Bool, index:Int){
        if(sortByUplifts){
    indexByUplifts = index;
        }else{
    indexByRecent = index;
        }
    }
    
    func buildUser(_ userObject:UserObject){
    let layout = UIView()
        layout.setInsets(UIEdgeInsets(top: -RefreshView.H, left: 0, bottom: 0, right: 0))
    
    scroll = UIScrollViewX()
        LayoutParams.alignParentLeftRight(subview: scroll)
        LayoutParams.alignParentTopBottom(subview: scroll)
    layout.addSubview(scroll);
    scroll.showsVerticalScrollIndicator = false
    scroll.backgroundColor = Color.theme
    TouchController.setUniversalOnTouchListener(scroll, allowSpreadMovement: true);
    
    let linear = VerticalLinearLayout()
        LayoutParams.alignParentScrollVertical(subview: linear)
    scroll.addSubview(linear);
    
    refreshView = RefreshView();
    linear.addSubview(refreshView);
    
    linear.addSubview(ContentCreator.divider());
        
        profileLayout = BasicViewGroup();
    LayoutParams.alignParentLeftRight(subview: profileLayout)
    LayoutParams.setHeight(view: profileLayout, height: 8 + 144 + 12 + 20 + 70)
    profileLayout.backgroundColor = Color.WHITE
    linear.addSubview(profileLayout);
    
    profile = RecyclerImageView(userObject.getThumb(), userObject.getThumbDimens()!);
    profileLayout.addSubview(profile);
    Layout.exact(profile, l: 8, t: 8, width: 144, height: 144);
    
    profileCover = UIView()
    profileLayout.addSubview(profileCover);
    Layout.exact(profileCover, l: 8, t: 8, width: 144, height: 144);
        
        TouchController.setUniversalOnTouchListener(profileCover, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback(execute: {
            let image = [self.user.getThumb()!]
            let dimensOuter = [self.user.getProfileDimens()!]
            let _ = WindowWithImages(name: self.user.getName()!, images: image, dimens: dimensOuter, startImage: 0, startImageView: self.profile, highQualityCallback: GetImagesCallback(executeSync: {
                return [self.user.getProfile()!]
            }));
        }))
    
    for i in 0 ..< 4{
    let label = UILabelX()
    label.textColor = Color.BLACK
        label.font = ViewController.typefaceR(14)
    profileLayout.addSubview(label);
    
    let value = UILabelX()
    ContentCreator.setUpBoldThemeStyle(value, size: 28, italics: false);
    profileLayout.addSubview(value);
    
    switch (i){
    case 0:
    label.text = "Posts and Comments:"
    value.text = String(userObject.getPostsAndComments())
    numPosts = value;
    Layout.wrapW(label, l: 8 + 144 + 16, t: 8, height: 36);
    Layout.exact(value, l: label.right + 4, t: 8, width: context.screenWidth, height: 36);
    break;
    case 1:
    label.text = "Uplifts Received:"
    value.text = String(userObject.getUplifts())
    Layout.wrapW(label, l: 8 + 144 + 16, t: 8 + 36, height: 36);
    Layout.exact(value, l: label.right + 4, t: 8 + 36, width: context.screenWidth, height: 36);
    numUplifts = value;
    break;
    case 2:
    label.text = "Ranking:"
    value.text = Misc.addSuffix(userObject.getRank())
    rank = value;
    Layout.wrapW(label, l: 8 + 144 + 16, t: 8 + 36 * 2, height: 36);
    Layout.exact(value, l: label.right + 4, t: 8 + 36 * 2, width: context.screenWidth, height: 36);
    break;
    case 3:
    label.text = "Days on Uplift:"
    value.text = String((Date().timeInMillis - userObject.object.createdAt!.timeInMillis) / 1000 / 60 / 60 / 24)
    Layout.wrapW(label, l: 8 + 144 + 16, t: 8 + 36 * 3, height: 36);
    Layout.exact(value, l: label.right + 4, t: 8 + 36 * 3, width: context.screenWidth, height: 36);
    break;
    default:break;
    }
    }
    
    let charityLabel = UILabelX()
    charityLabel.textColor = Color.BLACK
        charityLabel.font = ViewController.typefaceR(14)
    charityLabel.text = "Proceeds on uplifts donated to:"
    charityLabel.textAlignment = .center
    profileLayout.addSubview(charityLabel);
    let _ = Layout.wrapH(charityLabel, l: 0, t: 8 + 144 + 12, width: context.screenWidth);
    
    charityView = ProgressBar();
    profileLayout.addSubview(charityView);
    Layout.exact(charityView, l: context.screenWidth / 2 - 25, t: 8 + 144 + 12 + 20 + 10, width: 50, height: 50);
    
        sortSwitch = SortSwitch(comments: false, pageName: user.object.objectId!, callback: SortCallback(execute: { sortByUplifts in
            self.postsLayout.removeAllViews();
            self.postsLayout.addSubview(Update.loadingSpinner());
            Refresh.refreshUser(self, userObject, self.sortSwitch.byUplifts);
        }))
    
    linear.addSubview(ContentCreator.divider());
    linear.addSubview(sortSwitch);
    
    if(userObject.object.objectId == CurrentUser.userId()) {
    linear.addSubview(ContentCreator.divider());
    linear.addSubview(ContentCreator.composeButton());
    }
    
    postsLayout = VerticalLinearLayout()
        LayoutParams.alignParentLeftRight(subview: postsLayout)
    linear.addSubview(postsLayout);
    
    postsLayout.addSubview(Update.loadingSpinner());
    Refresh.refreshUser(self, userObject, sortSwitch.byUplifts);
        
        scroll.scrollChangedListeners.append({
            if (!LogIn.isLoggedIn() || !self.shown) {
                return;
            }
            
            if (!self.reachedBottom && linear.height - self.scroll.contentOffset.y - self.scroll.height < 1000) {
                Refresh.fetchNextUserItems(self, self.sortSwitch.byUplifts, 10);
            }
        })
    
    content = layout;
    }
    
    func populateProfile(userObject:UserObject, charityObject:CharityObject){
    
    profile.removeFromSuperview()
    charityView.removeFromSuperview()
    
    profile = RecyclerImageView(userObject.getThumb(), userObject.getThumbDimens()!);
    profileLayout.addSubview(profile);
    Layout.exact(profile, l: 8, t: 8, width: 144, height: 144);
    
    profileLayout.bringSubview(toFront: profileCover)
    
    numPosts.text = String(userObject.getPostsAndComments())
    numUplifts.text = String(userObject.getUplifts())
    rank.text = Misc.addSuffix(userObject.getRank())
    
    charityView = CharityView(charity: charityObject, isFullCard: false);
    profileLayout.addSubview(charityView);
    //instead of this: Layout.wrapCenterW(charityView, c: context.screenWidth / 2, t: 8 + 144 + 12 + 20);
        //this in swift:
        LayoutParams.alignParentTop(subview: charityView, margin: 8 + 144 + 12 + 20)
        LayoutParams.centerParentHorizontal(subview: charityView)
    }
    
    func populatePosts(fromTop:Bool){
        
    if(fromTop){
    postsShown = 0;
    }
    
    let index = getIndex(sortByUplifts: sortSwitch.byUplifts);
    let list = getPostArray(sortByUplifts: sortSwitch.byUplifts);
    
    let newPosts = VerticalLinearLayout()
        
        LayoutParams.alignParentLeftRight(subview: newPosts)
    
    for i in postsShown ..< min(index, list.count){
    
    if(i % 8 == 2){
    newPosts.addSubview(ContentCreator.divider());
    newPosts.addSubview(ContentCreator.adView());
    }
    
    newPosts.addSubview(ContentCreator.divider());
    newPosts.addSubview(PostView(postId: list[i], isComment: false, clickable: true));
    }
        
        Async.run(SyncInterface(runTask: {
            self.postsShown = index;
            self.reachedBottom = index >= list.count;
            
            if (fromTop) {
                self.postsLayout.removeAllViews();
            } else {
                if let bottom = self.postsLayout.viewWithTag(Tag.getTag("bottom")){
                    bottom.removeFromSuperview()
                }
            }
            
            self.postsLayout.addSubview(newPosts);
            
            if (self.reachedBottom) {
                self.postsLayout.addSubview(BottomView(windowWithUser: self));
            } else {
                self.postsLayout.addSubview(Update.loadingSpinner());
            }
            
            let _ = self.scroll.animate().translationY(0).setDuration(200).setInterpolator(.decelerate).setListener(nil);
            
            self.refreshView.setDefault();
            
            self.refreshing = false;
        }))
    }
    
    var failedZeroScroll = false;
    
    override func scrollActionOnFalseMove(v: UIView, touches: [UITouch], deltay: CGFloat) -> Bool {
        if(v != scroll && scroll.subviews.first!.height > scroll.height){
            return false;
        }
        
        if(scroll.contentOffset.y != 0 && scroll.contentOffset.y > -deltay){
            failedZeroScroll = true;
        }
        
        if (deltay >= 0 && scroll.contentOffset.y == 0 && !failedZeroScroll) {
            let refreshViewTrans = 30 * log((deltay) / 1 / 30 + 1);
            
            scroll.translationY = refreshViewTrans
            
            if (refreshViewTrans >= RefreshView.refreshH) {
                refreshView.setPoised();
            } else {
                refreshView.setDefault();
            }
            if (scroll.contentOffset.y != 0) {
                scroll.contentOffset = .zero
            }
            return true;
        } else {
            scroll.translationY = 0
        }
        return false;
    }
    
    override func scrollActionOnFalseUpCancel(v: UIView, touches: [UITouch], deltay: CGFloat) -> Bool {
        if(v != scroll && scroll.subviews.first!.height > scroll.height){
            return false;
        }
        
        failedZeroScroll = false;
        if (scroll.translationY >= RefreshView.refreshH) {
            
            Refresh.refreshUser(self, user, sortSwitch.byUplifts);
        } else {
            let _ = scroll.animate().translationY(0).setDuration(200).setInterpolator(.decelerate);
            refreshView.setDefault();
        }
        return false
    }
}
