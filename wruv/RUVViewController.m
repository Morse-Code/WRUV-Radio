//
//  RUVViewController.m
//  wruv
//
//  Created by Christopher Morse on 10/6/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import "RUVViewController.h"
#import "IIViewDeckController.h"



@implementation RUVViewController

@synthesize nowplaying, metadatas;
@synthesize toolBar, playButton, pauseButton;
@synthesize movieDuration;
@synthesize allowsAirPlay;
@synthesize stationArt = _stationArt;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    nowplaying.hidden = YES;
    metadatas.text = @"Loading...";
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:airplay.bounds];
    [airplay addSubview:volumeView];
    [volumeView setShowsVolumeSlider:YES];
    [volumeView setShowsRouteButton:YES];
    
    //    [self.menuButton setTitle:@"Back"];
    //    [self.menuButton setTarget:self.viewDeckController];
    //    [self.menuButton setAction:@selector(toggleLeftView)];
    
    [self setTitle:@"WRUV-Radio"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"left" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        
    // Choose your station ;)
	m3uPath = @"http://icecast.uvm.edu:8005/wruv_fm_256";
	
    wruvLive = [NSURL URLWithString:m3uPath];
    
    asset = [AVURLAsset URLAssetWithURL:wruvLive options:nil];
    playerItem = [AVPlayerItem playerItemWithAsset:asset];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [playerItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];
    [player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // Allow to play in background
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
	[[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // Receive remote events
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self.stationArt setImage:[UIImage imageNamed:@"wruv.png"]];
    
}

static Float64 secondsWithCMTimeOrZeroIfInvalid(CMTime time) {
    return CMTIME_IS_INVALID(time) ? 0.0f : CMTimeGetSeconds(time);
}

- (Float64)durationInSeconds {
    return secondsWithCMTimeOrZeroIfInvalid(self.movieDuration);
}

- (void)handleDurationDidChange {
    movieDuration = player.currentItem.duration;
    NSLog(@"current duration : %@", movieDuration);
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *pItem = (AVPlayerItem *)object;
        if (pItem.status == AVPlayerItemStatusReadyToPlay) {
            //NSLog(@"ready to play");
            metadatas.text = @"";
            [self playpause];
        }
    }
    if ([keyPath isEqualToString:@"timedMetadata"] && [self isPlaying]) {
        for (AVAssetTrack *track in player.currentItem.tracks) {
            for (AVPlayerItemTrack *item in player.currentItem.tracks) {
                if ([item.assetTrack.mediaType isEqual:AVMediaTypeAudio]) {
                    NSArray *meta = [playerItem timedMetadata];
                    for (AVMetadataItem *metaItem in meta) {
                        if(nowplaying.hidden == YES) {
                            nowplaying.hidden = NO;
                        }
                        NSString *source = metaItem.stringValue;
                        //NSLog(@"meta %@",source);
                        metadatas.text = source;
                    }
                }
			}
        }
    }
}

- (BOOL)isPlaying
{
	return [player rate] != 0.f;
}

- (void)showPauseButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[toolBar items]];
    [toolbarItems replaceObjectAtIndex:1 withObject:pauseButton];
    [toolbarItems removeObject:playButton];
    toolBar.items = toolbarItems;
}

- (void)showPlayButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[toolBar items]];
    [toolbarItems replaceObjectAtIndex:1 withObject:playButton];
    [toolbarItems removeObject:pauseButton];
    toolBar.items = toolbarItems;
}

- (void)playpause
{
	if ([self isPlaying])
	{
        [self showPauseButton];
	}
	else
	{
        [self showPlayButton];
	}
}

- (void)togglePlayPause {
    if ([self isPlaying]) {
        [player pause];
        [self showPlayButton];
    } else {
        [player play];
        [self showPauseButton];
    }
}

- (void)enablePlayerButtons
{
    self.playButton.enabled = YES;
    self.pauseButton.enabled = YES;
}

- (void)disablePlayerButtons
{
    self.playButton.enabled = NO;
    self.pauseButton.enabled = NO;
}

- (IBAction)play:(id)sender
{
	[player play];
    //    if (self.isPlaying) {
    //        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    //    }
    
    [self showPauseButton];
}

- (IBAction)pause:(id)sender
{
	[player pause];
    [self showPlayButton];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    NSLog(@"remoteControlReceivedWithEvent");
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [self togglePlayPause];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            break;
        default:
            break;
    }
}

- (void)viewDidUnload
{
    self.toolBar = nil;
    self.playButton = nil;
    self.pauseButton = nil;
    self.nowplaying = nil;
    self.metadatas = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


@end
