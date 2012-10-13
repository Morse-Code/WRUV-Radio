//
//  RUVViewController.h
//  wruv
//
//  Created by Christopher Morse on 10/6/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>




@class AVPlayer;
@class AVPlayerItem;

@interface RUVViewController : UIViewController {
    AVAsset *asset;
    AVPlayerItem *playerItem;
    AVPlayer *player;
    NSURL *wruvLive;
    NSString *m3uPath;
	IBOutlet UIView *airplay;
    IBOutlet UILabel *nowplaying;
    IBOutlet UILabel *metadatas;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UIBarButtonItem *playButton;
    IBOutlet UIBarButtonItem *pauseButton;
}

@property (nonatomic) BOOL *allowsAirPlay;
@property (nonatomic, retain) IBOutlet UILabel *nowplaying;
@property (nonatomic, retain) IBOutlet UILabel *metadatas;
@property (retain) IBOutlet UIToolbar *toolBar;
@property (retain) IBOutlet UIBarButtonItem *playButton;
@property (retain) IBOutlet UIBarButtonItem *pauseButton;
@property (nonatomic, assign) CMTime movieDuration;
@property (nonatomic, assign) IBOutlet UIImageView *stationArt;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context;
- (BOOL)isPlaying;
- (void)showPauseButton;
- (void)showPlayButton;
- (void)playpause;
- (void)enablePlayerButtons;
- (void)disablePlayerButtons;
- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;

//@property (nonatomic, assign) IBOutlet UIView *playControl;
//@property (nonatomic, assign) IBOutlet UIToolbar *controlBar;
//@property (nonatomic, assign) IBOutlet UIBarButtonItem *menuButton;

@end
