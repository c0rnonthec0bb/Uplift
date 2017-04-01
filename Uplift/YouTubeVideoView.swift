//
//  YouTubeVideoView.swift
//  Uplift
//
//  Created by Adam Cobb on 11/7/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class YouTubeVideoView: BasicViewGroup, YTPlayerViewDelegate {
    static var playingView:YouTubeVideoView?
    
    var m_width:CGFloat!, m_height:CGFloat!
    
    var m_videoId:String!
    var m_title:String!
    var m_thumbnail:Data!
    
    var loaded = false;
    
    var m_titleAndLink:TitleAndLinkView!
    var m_playerView:YTPlayerView!
    var m_blankView:BasicViewGroup!
    var m_playView:BasicViewGroup! //above video
    var m_imageView:RecyclerImageView? //youTube icon in m_playView
    
    let defaultTitle = "Title of YouTube Video Will Display Here";
    let defaultLink = "Complete Link to YouTube Video Will Display Here";
    let loadingTitle = "Loading YouTube Video Title...";
    let loadingLink = "Loading YouTube Video Link...";
    let errorTitle = "Error Loading YouTube Video";
    let errorLink = "Complete Link to YouTube Video Will Display Here";
    
    required init(coder: NSCoder?) {
        super.init(coder: coder)
    }
    
    convenience init(width:CGFloat){
        self.init(coder: nil)
        
        m_width = width;
        m_height = m_width * 9 / 16;
        
        LayoutParams.setWidth(view: self, width: m_width)
        LayoutParams.setHeight(view: self, height: m_height + TitleAndLinkView.H)
        
        m_titleAndLink = TitleAndLinkView(colorTheme: TitleAndLinkView.YOUTUBE, width: m_width);
        m_titleAndLink.populate(title: defaultTitle, link: defaultLink);
        addSubview(m_titleAndLink);
        Layout.exact(m_titleAndLink, width: m_width, height: TitleAndLinkView.H);
        
        m_playerView = YTPlayerView()
        m_playerView.isOpaque = false
        addSubview(m_playerView);
        Layout.exact(m_playerView, l: 0, t: TitleAndLinkView.H, width: m_width, height: m_height);
        
        m_blankView = BasicViewGroup()
        m_blankView.backgroundColor = Color.view_touchOpaque
        addSubview(m_blankView);
        Layout.exact(m_blankView, l: 0, t: TitleAndLinkView.H, width: m_width, height: m_height);
        
        let s1 = ContentCreator.shadow(top: true, alpha: 0.1);
        m_blankView.addSubview(s1);
        Layout.exact(s1, width: m_width, height: 5);
        
        let s2 = ContentCreator.shadow(top: false, alpha: 0.1);
        m_blankView.addSubview(s2);
        Layout.exactUp(s2, l: 0, b: m_height, width: m_width, height: 5);
    }
    
    func populate(videoId:String, title:String, thumbnail:Data, thumbnailDimens:[Int]){
    populate(videoId: videoId, title: title, thumbnail: thumbnail, thumbnailWidth: thumbnailDimens[0], thumbnailHeight: thumbnailDimens[1]);
    }
    
    func populate(videoId:String, title:String, thumbnail:Data, thumbnailWidth:Int, thumbnailHeight:Int){
    m_videoId = videoId;
    m_title = title;
    m_thumbnail = thumbnail;
    loaded = true;
    
    m_blankView.isHiddenX = true
    
    if m_playerView.playerState() == .playing {
    m_playerView.stopVideo()
    }
        
        m_titleAndLink.populate(title: m_title, link: "https://www.youtube.com/watch?v=" + m_videoId, callback: ClickCallback{
            let _ = WindowWithWebView(link: "https://www.youtube.com/watch?v=" + self.m_videoId, title: self.m_title);
            self.stopPlayingVideo();
        })
    
        if let m_imageView = m_imageView{
            m_imageView.removeFromSuperview()
            m_playView.removeFromSuperview()
        }
    
    m_imageView = RecyclerImageView(m_thumbnail, thumbnailWidth, thumbnailHeight);
    m_imageView!.setViewDimens(width: m_width, height: m_height);
    addSubview(m_imageView!);
    Layout.exact(m_imageView!,l:  0,t:  TitleAndLinkView.H,width:  m_width,height:  m_height);
    
    m_playView = BasicViewGroup();
    addSubview(m_playView);
    Layout.exact(m_playView, l: 0, t: TitleAndLinkView.H, width: m_width, height: m_height);
    
    let playIcon = UIImageView()
    playIcon.image = #imageLiteral(resourceName: "youtube_red")
    m_playView.addSubview(playIcon)
    Layout.exact(playIcon, l: m_width / 2 - 36, t: m_height / 2 - 36, width: 72, height: 72);
    
    let s1 = ContentCreator.shadow(top: true, alpha: 0.1);
    m_playView.addSubview(s1)
    Layout.exact(s1, width: m_width, height: 5);
    
    let s2 = ContentCreator.shadow(top: false, alpha: 0.1);
    m_playView.addSubview(s2);
    Layout.exactUp(s2, l: 0, b: m_height, width: m_width,height: 5);
        
        TouchController.setUniversalOnTouchListener(m_playView, allowSpreadMovement: true, whiteWhenOff: false, clickCallback: ClickCallback{
            self.playVideo()
        })
    }
    
    func populate(videoId:String){
    loaded = false;
    
    m_blankView.isHiddenX = false
        
        if m_playerView.playerState() == .playing {
            m_playerView.stopVideo()
        }
        
        if let m_imageView = m_imageView{
            m_imageView.removeFromSuperview()
            m_playView.removeFromSuperview()
        }
    
    if(videoId == ""){
    m_titleAndLink.populate(title: defaultTitle, link: defaultLink);
    return;
    }
    
    let link = "https://www.youtube.com/watch?v=" + videoId;
        
        var title:String?
        var image:UIImage?
    
    m_titleAndLink.populate(title: loadingTitle, link: loadingLink);
        
        Async.run(Async.PRIORITY_INTERNETSMALL, AsyncSyncSuccessInterface(runTask: {
            
            let url = URL(string: "http://www.youtube.com/oembed?url=" +
                link + "&format=json")
            if url == nil{
                return false
            }
            
            let titleData = try Data(contentsOf: url!)
            
            let titleDict = try JSONSerialization.jsonObject(with: titleData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary

            if titleDict == nil{
                return false
            }
            
            title = titleDict!.value(forKey: "title") as? String
            
            if let title = title{
                print("title: " + title)
            }
            
            if title == nil{
                return false
            }
            
            Async.run(SyncInterface(runTask: {
                self.m_titleAndLink.populate(title: self.loadingTitle, link: link);
            }))
            
            let thumbnailURL = URL(string: "http://img.youtube.com/vi/" + videoId + "/mqdefault.jpg")
            
            if thumbnailURL == nil{
                return false
            }
            
            let data = try? Data(contentsOf: thumbnailURL!)
            
            if data == nil{
                return false
            }
            
            image = UIImage(data: data!)
            
            if image == nil{
                return false
            }
            
            return true
            
            }, afterTask: { (success, messsage) in
                if success{
                    self.populate(videoId: videoId, title: title!, thumbnail: Misc.encodeImage(image!.scaleImage(toSize: CGSize(width: 512, height: 288)))!, thumbnailWidth: 512, thumbnailHeight: 288);
                }else{
                    self.m_titleAndLink.populate(title: self.errorTitle, link: self.errorLink)
                }
        }))
    
    /*Async.run(Async.PRIORITY_INTERNETSMALL, new AsyncSyncSuccessInterface() {
    @Override
    public boolean runTask() throws Exception {
    URL embededURL = new URL("http://www.youtube.com/oembed?url=" +
    link + "&format=json");
    
    title.o = new JSONObject(IOUtils.toString(embededURL)).getString("title");
    return true;
    }
    
    @Override
    public void afterTask(boolean success, String message) {
    if (success) {
    m_titleAndLink.populate(loadingTitle, link);
    
    m_thumbnailView.setVisibility(VISIBLE);
    try {
    m_thumbnailLoader.setVideo(videoId);
    } catch (Exception e) {
    m_thumbnailView.initialize(context.getString(R.string.api_key), new YouTubeThumbnailView.OnInitializedListener() {
    @Override
    public void onInitializationSuccess(YouTubeThumbnailView youTubeThumbnailView, YouTubeThumbnailLoader youTubeThumbnailLoader) {
    m_thumbnailLoader = youTubeThumbnailLoader;
    m_thumbnailLoader.setOnThumbnailLoadedListener(new YouTubeThumbnailLoader.OnThumbnailLoadedListener() {
    @Override
    public void onThumbnailLoaded(YouTubeThumbnailView youTubeThumbnailView, String s) {
    Bitmap bitmap = Bitmap.createBitmap(m_width, m_height, Bitmap.Config.ARGB_8888);
    Canvas canvas = new Canvas(bitmap);
    m_thumbnailView.draw(canvas);
    populate(videoId, title.o, Misc.encodeBitmap(Bitmap.createScaledBitmap(bitmap, 512, 288, false)), 512, 288);
    bitmap.recycle();
    }
    
    @Override
    public void onThumbnailError(YouTubeThumbnailView youTubeThumbnailView, YouTubeThumbnailLoader.ErrorReason errorReason) {
    m_titleAndLink.populate(errorTitle, errorLink);
    }
    });
    m_thumbnailLoader.setVideo(videoId);
    }
    
    @Override
    public void onInitializationFailure(YouTubeThumbnailView youTubeThumbnailView, YouTubeInitializationResult youTubeInitializationResult) {
    Toast.makeText(context, "Failed to initialize YouTube plugin.", Toast.LENGTH_SHORT).show();
    }
    });
    }
    } else {
    m_titleAndLink.populate(errorTitle, errorLink);
    }
    }
    });*/
    }
    
    func playVideo(){
        
        if(!loaded || m_playerView.playerState() == .playing){
    return;
        }
    
        if let playingView = YouTubeVideoView.playingView{
            playingView.stopPlayingVideo();
        }
    
    YouTubeVideoView.playingView = self;
    
    m_playView.isHiddenX = true
        if let m_imageView = m_imageView{
            m_imageView.isHiddenX = true
        }
         
         m_playerView.delegate = self
        
        m_playerView.load(withVideoId: m_videoId);
    
        if let webView = m_playerView.webView{
            webView.backgroundColor = .black
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .ended{
            stopPlayingVideo()
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        stopPlayingVideo();
    }
    
    func stopPlayingVideo(){
        if(!loaded){
            return;
        }
    
    m_playView.isHiddenX = false
        if let m_imageView = m_imageView{
            m_imageView.isHiddenX = false
        }
    
        if m_playerView.playerState() == .playing {
            m_playerView.stopVideo()
        }
    }
}
