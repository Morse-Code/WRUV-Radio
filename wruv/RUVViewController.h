//
//  RUVViewController.h
//  wruv
//
//  Created by Christopher Morse on 10/6/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@interface RUVViewController : UIViewController


@property (nonatomic, assign) IBOutlet UIImageView *stationArt;
@property (nonatomic, assign) IBOutlet UIButton *playButton;
@property (nonatomic, assign) IBOutlet UIView *playControl;
@property (nonatomic, retain) NSString *m3uPath;
@property (nonatomic, retain) NSURL *wruvLive;
//@property (nonatomic, assign) IBOutlet UIToolbar *controlBar;
//@property (nonatomic, assign) IBOutlet UIBarButtonItem *menuButton;

- (IBAction) playToggle:(UIButton *)sender;
@end
